class Solution
  class MentorRequest
    class Lock
      include Mandate

      initialize_with :request, :mentor

      def call
        ActiveRecord::Base.transaction do
          # This is a DB lock (The naming is confusing!)
          request.lock!

          # Guard against not being lockable
          raise SolutionLockedByAnotherMentorError unless request.lockable_by?(mentor)

          request.update!(
            locked_until: Time.zone.now + 30.minutes,
            locked_by: mentor
          )
        end
      end
    end
  end
end
