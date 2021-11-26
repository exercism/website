class Solution
  class SearchCommunitySolutions
    include Mandate

    DEFAULT_PAGE = 1
    DEFAULT_PER = 25
    MAX_ROWS = 10_000

    def self.default_per
      DEFAULT_PER
    end

    def initialize(exercise, page: nil, per: nil, order: nil,
                   criteria: nil, tests_status: nil, mentoring_status: nil, sync_status: nil)
      @exercise = exercise
      @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE # rubocop:disable Style/ConditionalAssignment
      @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per # rubocop:disable Style/ConditionalAssignment
      @order = order
      @criteria = criteria
      @tests_status = tests_status
      @mentoring_status = mentoring_status
      @sync_status = sync_status
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
      Fallback.(exercise, page, per, order, criteria, tests_status, mentoring_status, sync_status)
    end

    private
    attr_reader :exercise, :per, :page, :order, :solutions, :criteria, :tests_status, :mentoring_status, :sync_status

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
            @sync_status.nil? ? nil : { term: { 'out_of_date': @sync_status == :out_of_date } },
            @mentoring_status.blank? ? nil : { term: { 'mentoring_status': @mentoring_status.to_s } },
            @tests_status.blank? ? nil : { term: { 'published_iteration.tests_status': @tests_status.to_s } },
            @criteria.blank? ? nil : {
              query_string: {
                query: criteria.split(' ').map { |c| "*#{c}*" }.join(' AND '),
                fields: ['user.handle', 'published_iteration.code']
              }
            }
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

      initialize_with :exercise, :page, :per, :order, :criteria, :tests_status, :mentoring_status, :sync_status

      def call
        @solutions = exercise.solutions.published

        filter_criteria!
        filter_tests_status!
        filter_mentoring_status!
        filter_sync_status!
        sort!

        @solutions.page(page).per(per)
      end

      private
      attr_reader :solutions

      def filter_criteria!
        return if @criteria.blank?

        @solutions = @solutions.joins(:user).where("users.handle LIKE ?", "%#{criteria}%")
      end

      def filter_tests_status!
        return if tests_status.blank?

        @solutions = @solutions.joins(published_iteration: :submission).where('submissions.tests_status': tests_status)
      end

      def filter_mentoring_status!
        return if mentoring_status.blank?

        @solutions = @solutions.where(mentoring_status: mentoring_status)
      end

      def filter_sync_status!
        case sync_status&.to_sym
        when :up_to_date
          @solutions = @solutions.where(git_important_files_hash: exercise.git_important_files_hash)
        when :out_of_date
          @solutions = @solutions.where.not(git_important_files_hash: exercise.git_important_files_hash)
        end
      end

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
