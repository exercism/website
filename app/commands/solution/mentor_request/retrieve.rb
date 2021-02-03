class Solution
  class MentorRequest
    class Retrieve
      include Mandate

      REQUESTS_PER_PAGE = 10

      def initialize(user, page, track_id: nil, exercise_ids: nil)
        @user = user
        @page = page
        @track_id = track_id
        @exercise_ids = exercise_ids
      end

      def call
        setup!
        filter!
        sort!
        paginate!

        @requests
      end

      private
      attr_reader :user, :page, :track_id, :exercise_ids

      def setup!
        @requests = Solution::MentorRequest.
          joins(:solution).
          includes(solution: [:user, { exercise: :track }]).
          pending.
          unlocked.
          where.not('solutions.user_id': user.id)
      end

      def filter!
        filter_track!
        filter_exercises!
      end

      def filter_track!
        return if track_id.blank?

        @requests = @requests.
          joins(solution: :track).
          where('exercises.track_id': track_id)
      end

      def filter_exercises!
        return if exercise_ids.blank?

        @requests = @requests.
          joins(solution: :exercise).
          where('solutions.exercise_id': exercise_ids)
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
