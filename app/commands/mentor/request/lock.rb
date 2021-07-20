module Mentor
  class Request
    class Lock
      include Mandate

      initialize_with :request, :mentor

      def call
        ActiveRecord::Base.transaction do
          # This is a DB lock (The naming is confusing!)
          request.lock!

          # Guard against not being lockable
          raise SolutionLockedByAnotherMentorError unless request.lockable_by?(mentor)
          raise MentorSolutionLockLimitReachedError if mentor.locks.size >= Mentor::RequestLock::MAX_LOCKS_PER_MENTOR

          Mentor::RequestLock.create!(
            request: request,
            locked_until: Time.zone.now + 30.minutes,
            locked_by: mentor
          )
        end
      end
    end
  end
end
