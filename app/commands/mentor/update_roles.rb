module Mentor
  class UpdateRoles
    include Mandate

    initialize_with :mentor

    def call
      if supermentor?
        mentor.update(roles: mentor.roles.add(SUPERMENTOR_ROLE))
      else
        mentor.update(roles: mentor.roles.delete(SUPERMENTOR_ROLE))
      end
    end

    private
    def supermentor?
      mentor.mentor? &&
        mentor.mentor_satisfaction_percentage.to_i >= MIN_SATISFACTION_PERCENTAGE &&
        mentor.mentor_discussions.finished.count >= MIN_FINISHED_MENTORING_SESSIONS
    end

    SUPERMENTOR_ROLE = :supermentor
    MIN_FINISHED_MENTORING_SESSIONS = 100
    MIN_SATISFACTION_PERCENTAGE = 95
    private_constant :SUPERMENTOR_ROLE, :MIN_FINISHED_MENTORING_SESSIONS, :MIN_SATISFACTION_PERCENTAGE
  end
end
