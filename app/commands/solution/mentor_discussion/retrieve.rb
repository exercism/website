class Solution
  class MentorDiscussion
    class Retrieve
      include Mandate

      REQUESTS_PER_PAGE = 10

      initialize_with :user, :page

      def call
        discussions.page(page).per(REQUESTS_PER_PAGE).tap do |res|
          filtered_tracks = Track.where(id: discussions.select('exercises.track_id'))
          res.class.define_method(:tracks) { filtered_tracks }
        end
      end

      memoize
      def discussions
        Solution::MentorDiscussion.
          joins(solution: :exercise).
          includes(solution: [:user, { exercise: :track }]).
          where(mentor: user).
          requires_mentor_action
      end
    end
  end
end
