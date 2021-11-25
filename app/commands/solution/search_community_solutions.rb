class Solution
  class SearchCommunitySolutions
    include Mandate

    DEFAULT_PAGE = 1
    DEFAULT_PER = 25
    MAX_ROWS = 10_000

    def self.default_per
      DEFAULT_PER
    end

    def initialize(exercise, page: nil, per: nil, order: nil, criteria: nil, status: nil, mentoring_status: nil, up_to_date: nil)
      @exercise = exercise
      @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE # rubocop:disable Style/ConditionalAssignment
      @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per # rubocop:disable Style/ConditionalAssignment
      @order = order
      @criteria = criteria
      @status = status
      @mentoring_status = mentoring_status
      @up_to_date = up_to_date
    end

    def call
      # ES can only handle paginating up to 10_000 rows.
      # If it's above that, return nothing
      return Kaminari.paginate_array([], total_count: MAX_ROWS).page(page).per(per) if from + per > MAX_ROWS

      results = Exercism.opensearch_client.search(index: Solution::OPENSEARCH_INDEX, body: search_body)

      solution_ids = results["hits"]["hits"].map { |hit| hit["_source"]["id"] }
      solutions = solution_ids.present? ?
        Solution.where(id: solution_ids).
          includes(*SerializeSolutions::NP1_INCLUDES).
          order(Arel.sql("FIND_IN_SET(id, '#{solution_ids.join(',')}')")).
          to_a : []

      total_count = [results["hits"]["total"]["value"].to_i, MAX_ROWS].min

      Kaminari.paginate_array(solutions, total_count: total_count).
        page(page).per(per)
    rescue StandardError => e
      Bugsnag.notify(e)
      Fallback.(exercise, page, per, order, criteria, status, mentoring_status, up_to_date)
    end

    private
    attr_reader :exercise, :per, :page, :order, :solutions, :criteria, :status, :mentoring_status, :up_to_date

    def search_body
      {
        query: search_query,
        sort: search_sort,

        # Only return the solution IDs, not the entire document, to improve performance
        _source: [:id],

        # Paging information
        from: from,
        size: per
      }
    end

    memoize
    def from
      (page - 1) * per
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
      case order&.to_sym
      when :newest
        [{ published_at: { order: :desc, unmapped_type: "date" } }]
      else # :most_starred
        [{ num_stars: { order: :desc, unmapped_type: "integer" } }]
      end
    end

    class Fallback
      include Mandate

      initialize_with :exercise, :page, :per, :order, :criteria, :status, :mentoring_status, :up_to_date

      def call
        @solutions = exercise.solutions.published
        @solutions = @solutions.joins(:user).where("users.handle LIKE ?", "%#{criteria}%") if @criteria.present?

        sort!

        @solutions.page(page).per(per)

        # TODO: use status: nil, up_to_date: nil, mentoring_status: nil
        # TODO: order
      end

      private
      attr_reader :solutions

      def sort!
        case order&.to_sym
        when :newest
          @solutions = @solutions.order(published_at: :desc)
        else # :most_starred
          @solutions = @solutions.order(num_stars: :desc)
        end
      end
    end
  end
end
