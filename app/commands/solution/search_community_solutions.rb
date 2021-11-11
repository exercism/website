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
      results = Exercism.opensearch_client.search(index: Solution::OPENSEARCH_INDEX, body: search_body)

      solution_ids = results["hits"]["hits"].map { |hit| hit["_source"]["id"] }
      solutions = solution_ids.present? ?
        Solution.where(id: solution_ids).
          includes(:exercise, :track).
          order(Arel.sql("FIND_IN_SET(id, '#{solution_ids.join(',')}')")).
          to_a : []

      total_count = results["hits"]["total"]["value"].to_i
      Kaminari.paginate_array(solutions, total_count: total_count).
        page(page).per(per)
    rescue StandardError => e
      Bugsnag.notify(e)
      Fallback.(exercise, page, per, criteria)
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

    class Fallback
      include Mandate

      initialize_with :exercise, :page, :per, :criteria

      def call
        solutions = exercise.solutions.published.order(num_stars: :desc, id: :desc)
        solutions = solutions.joins(:user).where("users.handle LIKE ?", "%#{criteria}%") if @criteria.present?
        solutions.page(page).per(per)
      end
    end
  end
end
