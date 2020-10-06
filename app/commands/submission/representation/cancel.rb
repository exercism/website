class Submission
  class Representation
    class Cancel
      include Mandate

      def initialize(submission_uuid)
        @submission_uuid = submission_uuid
      end

      def call
        RestClient.post "#{orchestrator_url}/submissions/cancel", {
          submission_uuid: submission_uuid
        }
      end

      private
      attr_reader :submission_uuid

      def orchestrator_url
        Exercism.config.tooling_orchestrator_url
      end
    end
  end
end
