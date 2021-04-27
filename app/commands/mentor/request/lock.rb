module Mentor
  class Request
    class Lock
      include Mandate

      initialize_with :request, :mentor

      # TODO: Add a guard that a mentor should only have
      # two solutions locked to them at any time. When someone
      # hits 'start discussion' that should remove the lock.

      def call
        ActiveRecord::Base.transaction do
          # This is a DB lock (The naming is confusing!)
          request.lock!

          # Guard against not being lockable
          raise SolutionLockedByAnotherMentorError unless request.lockable_by?(mentor)

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
