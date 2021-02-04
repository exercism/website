class Solution
  class MentorRequest
    class Retrieve
      include Mandate

      REQUESTS_PER_PAGE = 10

      def initialize(user,
                     page: 1,
                     track_slug: nil, exercise_slugs: nil,
                     sorted: true,
                     paginated: true)
        @user = user
        @page = page
        @track_slug = track_slug
        @exercise_slugs = exercise_slugs
        @sorted = sorted
        @paginated = paginated
      end

      def call
        setup!
        filter!
        sort! if sorted
        paginate! if paginated

        @requests
      end

      private
      attr_reader :user, :page, :track_slug, :exercise_slugs,
        :sorted, :paginated

      def setup!
        @requests = Solution::MentorRequest.
          joins(:solution).
          includes(solution: [:user, { exercise: :track }]).
          pending.
          unlocked.
          where.not('solutions.user_id': user.id)
      end

      def filter!
        if exercise_slugs.present?
          filter_exercises!
        else
          filter_track!
        end
      end

      def filter_track!
        return if track_slug.blank?

        @requests = @requests.
          joins(solution: :track).
          where('tracks.slug': track_slug)
      end

      def filter_exercises!
        return if track_slug.blank?
        return if exercise_slugs.blank?

        @requests = @requests.
          joins(solution: { exercise: :track }).
          where('tracks.slug': track_slug).
          where('exercises.slug': exercise_slugs)
      end

      def sort!
        @requests = @requests.
          order('created_at ASC')
      end

      def paginate!
        @requests = @requests.
          page(page).per(REQUESTS_PER_PAGE)
      end
    end
  end
end
