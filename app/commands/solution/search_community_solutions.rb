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

      solution_ids = results["hits"]["hits"].map { |hit| hit["_source"]["id"] }
      solutions = solution_ids.present? ?
        Solution.where(id: solution_ids).
          includes(:exercise, :track).
          order(Arel.sql("FIND_IN_SET(id, '#{solution_ids.join(',')}')")).
          to_a : []

      Kaminari.paginate_array(
        solutions,
        total_count: results["hits"]["total"]["value"].to_i
      ).page(page).per(per)
    end

    private
    attr_reader :exercise, :per, :page, :solutions, :criteria

    def search_body
      {
        query: search_query,
        sort: search_sort,

        # Only return the solution IDs, not the entire document, to improve performance
        _source: [:id],

        # Paging information
        from: (page - 1) * per,
        size: per
      }
    end

    def search_query
      {
        bool: {
          must: [
            { term: { 'exercise.id': exercise.id } },
            { term: { status: 'published' } },
            @criteria.blank? ? nil : { wildcard: { 'user.handle': "*#{criteria}*" } }
          ].compact
        }
      }
    end

    def search_sort
      [
        { num_stars: { order: :desc } },
        { id: { order: :desc } }
      ]
    end

    memoize
    def client
      # TODO: use Exercism.opensearch_client once the config gem has been updated
      Elasticsearch::Client.new(
        url: ENV['OPENSEARCH_HOST'],
        user: ENV['OPENSEARCH_USER'],
        password: ENV['OPENSEARCH_PASSWORD'],
        transport_options: { ssl: { verify: ENV['OPENSEARCH_VERIFY_SSL'] != 'false' } }
      )
    end
  end
end
