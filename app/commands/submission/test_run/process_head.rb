class Submission
  class TestRun
    class ProcessHead < Process
      private
      def broadcast!; end

      def update_status!(status)
        submission.with_lock do
          return if submission.tests_cancelled?

          solution.send("tests_#{status}!")
        end
      end
    end
  end
end
