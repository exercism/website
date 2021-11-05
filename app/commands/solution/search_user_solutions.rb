class Solution
  class SearchUserSolutions
    include Mandate

    DEFAULT_PAGE = 1
    DEFAULT_PER = 25

    def self.default_per
      DEFAULT_PER
    end

    def initialize(user, criteria: nil, track_slug: nil, status: nil, mentoring_status: nil, page: nil, per: nil, order: nil)
      @user = user
      @criteria = criteria
      @track_slug = track_slug
      @status = status
      @mentoring_status = mentoring_status
      @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
      @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per
      @order = order
    end

    def call
      results = client.search(index: 'solutions', body: search_body)

      solution_ids = results["hits"]["hits"].map { |hit| hit["_source"]["id"] }
      solutions = Solution.where(id: solution_ids).
        includes(:exercise, :track).
        order(Arel.sql("FIND_IN_SET(id, '#{solution_ids.join(',')}')")).
        to_a

      total_count = results["hits"]["total"]["value"].to_i
      Kaminari.paginate_array(solutions, total_count: total_count).
        page(page).per(per)
    end

    private
    attr_reader :user, :criteria, :track_slug, :status, :mentoring_status,
      :per, :page, :order,
      :solutions

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
            { term: { 'user.id': user.id } },
            track_slug.blank? ? nil : { term: { 'track.slug': track_slug } },
            status.blank? ? nil : { term: { status: status } },
            mentoring_status.blank? ? nil : { term: { mentoring_status: mentoring_status } },
            criteria.blank? ? nil : { multi_match: { query: "*#{criteria}*", fields: ['exercise.title', 'track.title'] } }
          ].compact
        }
      }
    end

    def search_sort
      return '_score' if criteria.present?

      [{ last_iterated_at: { order: order&.to_sym == :oldest_first ? :asc : :desc } }]
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
