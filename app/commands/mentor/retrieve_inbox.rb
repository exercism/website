module Mentor
  class RetrieveInbox
    include Mandate

    initialize_with :user

    def call
      Solution::MentorDiscussion.
        includes(solution: [:user, { exercise: :track }]).
        where(mentor: user).
        requires_mentor_action
    end
  end
end
