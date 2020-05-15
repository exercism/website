class SolutionLockedByAnotherMentorError < RuntimeError; end

module Mentor
  class LockRequest

    include Mandate

    initialize_with :mentor, :request

    def call
      ActiveRecord::Base.transaction do
        request.lock!

        # Guard against not being lockable
        raise SolutionLockedByAnotherMentorError unless request.lockable_by?(mentor)

        request.update!(
          locked_until: Time.now + 30.minutes,
          locked_by: mentor
        )
      end
    end
  end
end


