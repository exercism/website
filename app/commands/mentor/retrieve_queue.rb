module Mentor
  class RetrieveQueue
    include Mandate

    initialize_with :user

    def call
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
