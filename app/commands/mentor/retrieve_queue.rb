module Mentor
  class RetrieveQueue
    include Mandate

    initialize_with :user

    def call
      Solution::MentorRequest.
        joins(:solution).
        pending.
        unlocked.
        where.not('solutions.user_id': user.id).
        order('created_at ASC')
    end
  end
end
