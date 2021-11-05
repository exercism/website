class Solution
  class SearchCommunitySolutions
    include Mandate

    DEFAULT_PAGE = 1
    DEFAULT_PER = 25

    def self.default_per
      DEFAULT_PER
    end

    def initialize(exercise, page: nil, per: nil, criteria: nil)
      @exercise = exercise
      @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE # rubocop:disable Style/ConditionalAssignment
      @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per # rubocop:disable Style/ConditionalAssignment
      @criteria = criteria
    end

    def call
      results = client.search(index: 'solutions', body: search_body)

      solution_ids = results["hits"]["hits"].map { |hit| hit["_id"] }
      solutions = Solution.where(id: solution_ids).
        order(Arel.sql("FIND_IN_SET(id, '#{solution_ids.join(',')}')")).
        to_a

      total_count = results["hits"]["total"]["value"].to_i
      Kaminari.paginate_array(solutions, total_count: total_count).
        page(page).per(per)
    end

    private
    attr_reader :exercise, :per, :page, :solutions, :criteria

    def search_body
      {
        query: {
          exists: { field: :published_at },
          wildcard: @criteria.blank? ? nil : { author_handle: "*#{criteria}*" }
        },
        sort: [
          { 'num_stars': { order: 'desc' } },
          { 'id': { order: 'desc' } }
        ],
        stored_fields: [], # We're not interested in the document itself
        from: page * per,
        size: per
      }
    end

    memoize
    def client
      Elasticsearch::Client.new(
        url: ENV['OPENSEARCH_HOST'],
        user: ENV['OPENSEARCH_USER'],
        password: ENV['OPENSEARCH_PASSWORD'],
        transport_options: { ssl: { verify: ENV['OPENSEARCH_VERIFY_SSL'] != 'false' } }
      )
    end
  end
end
