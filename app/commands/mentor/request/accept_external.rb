module Mentor
  class Request
    class AcceptExternal
      include Mandate

      initialize_with :mentor, :solution

      def call
        Mentor::Request.transaction do
          request = Mentor::Request.create!(
            solution:,
            comment_markdown: "This is a private review session",
            external: true
          )
          request.fulfilled!
          Mentor::Discussion.create!(
            mentor:,
            request:,
            awaiting_student_since: Time.current,
            external: true
          )
        end
      end
    end
  end
end
