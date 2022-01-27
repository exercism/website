class Submission
  class TestRun
    class Init
      include Mandate

      def initialize(submission, type: :submission, git_sha: nil, run_in_background: false)
        @submission = submission
        @type = type.to_sym
        @git_sha = git_sha || submission.git_sha
        @run_in_background = !!run_in_background
      end

      def call
        ToolingJob::Create.(submission, :test_runner, git_sha: git_sha, run_in_background: run_in_background).tap do
          update_status!
        end
      end

      private
      attr_reader :submission, :git_sha, :type, :run_in_background

      def update_status!
        if type == :solution
          submission.solution.update_published_iteration_head_tests_status!(:queued)
        else
          submission.tests_queued!
        end
      end
    end
  end
end
