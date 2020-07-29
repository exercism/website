class Iteration
  class Representation
    class Cancel
      include Mandate

      def initialize(iteration_uuid)
        @iteration_uuid = iteration_uuid
      end

      def call
        RestClient.post "#{orchestrator_url}/iterations/cancel", {
          iteration_uuid: iteration_uuid
        }
      end

      private
      attr_reader :iteration_uuid

      def orchestrator_url
        Exercism.config.tooling_orchestrator_url
      end
    end
  end
end
