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
      @order = order&.to_sym
    end

    def call
      results = Exercism.opensearch_client.search(
        index: Solution::OPENSEARCH_INDEX,
        body: search_body,
        timeout: TIMEOUT,
        allow_partial_search_results: false
      )

      solution_ids = results["hits"]["hits"].map { |hit| hit["_source"]["id"] }
      solutions = solution_ids.present? ?
        Solution.where(id: solution_ids).
          includes(*SerializeSolutions::NP1_INCLUDES).
          order(Arel.sql("FIND_IN_SET(id, '#{solution_ids.join(',')}')")).
          to_a : []

      total_count = results["hits"]["total"]["value"].to_i
      Kaminari.paginate_array(solutions, total_count: total_count).
        page(page).per(per)
    rescue StandardError => e
      Bugsnag.notify(e)
      Fallback.(user, page, per, track_slug, status, mentoring_status, criteria, order)
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
            track_slug.blank? ? nil : { terms: { 'track.slug': [track_slug].flatten } },
            status.blank? ? nil : { terms: { status: [status].flatten } },
            mentoring_status.blank? ? nil : { terms: { mentoring_status: [mentoring_status].flatten } },
            criteria.blank? ? nil : {
              query_string: {
                query: criteria.split(' ').map { |c| "*#{c}*" }.join(' AND '),
                fields: ['exercise.title', 'track.title']
              }
            }
          ].compact
        }
      }
    end

    def search_sort
      case order
      when :newest_first
        [{ published_at: { order: :desc, unmapped_type: "date" } }]
      when :oldest_first
        [{ published_at: { order: :asc, unmapped_type: "date" } }]
      else # :most_starred
        [{ num_stars: { order: :desc, unmapped_type: "integer" } }]
      end
    end

    TIMEOUT = '100ms'.freeze
    private_constant :TIMEOUT

    class Fallback
      include Mandate

      initialize_with :user, :page, :per, :track_slug, :status, :mentoring_status, :criteria, :order

      def call
        @solutions = user.solutions
        filter_criteria!
        filter_track!
        filter_status!
        filter_mentoring_status!
        sort!

        @solutions.page(page).per(per)
      end

      private
      attr_reader :solutions

      def filter_criteria!
        return if criteria.blank?

        @solutions = @solutions.joins(exercise: :track)
        criteria.strip.split(" ").each do |crit|
          @solutions = @solutions.where(
            "exercises.title LIKE ? OR tracks.title LIKE ?",
            "%#{crit}%",
            "%#{crit}%"
          )
        end
      end

      def filter_track!
        return if track_slug.blank?

        @solutions = @solutions.joins(exercise: :track).
          where('tracks.slug': track_slug)
      end

      def filter_status!
        return if status.blank?

        @solutions = @solutions.where(status: status)
      end

      def filter_mentoring_status!
        return if mentoring_status.blank?

        @solutions = @solutions.where(mentoring_status: mentoring_status)
      end

      def sort!
        case order
        when :newest_first
          @solutions = @solutions.order(id: :desc)
        when :oldest_first
          @solutions = @solutions.order(id: :asc)
        else # :most_starred
          @solutions = @solutions.order(num_stars: :desc)
        end
      end
    end
  end
end
