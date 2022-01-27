class Submission
  class Representation
    class Init
      include Mandate

      initialize_with :submission

      def call
        ToolingJob::Create.(submission, :representer)
        submission.representation_queued!
      end
    end
  end
end
