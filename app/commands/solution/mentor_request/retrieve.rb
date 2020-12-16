class Solution
  class MentorRequest
    class Retrieve
      include Mandate

      REQUESTS_PER_PAGE = 10

      initialize_with :user, :page

      def call
        requests.page(page).per(REQUESTS_PER_PAGE)
      end

      memoize
      def requests
        Solution::MentorRequest.
          joins(:solution).
          includes(solution: [:user, { exercise: :track }]).
          pending.
          unlocked.
          where.not('solutions.user_id': user.id).
          order('created_at ASC')
      end
    end
  end
end
