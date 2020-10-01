module ToolingJob
  class Cancel
    include Mandate

    initialize_with :iteration_uuid

    def call
      iteration = Iteration.find_by!(uuid: iteration_uuid)

      RestClient.post "#{orchestrator_url}/iterations/cancel", {
        iteration_uuid: iteration_uuid
      }

      iteration.analysis_cancelled!
      iteration.representation_cancelled!
    end

    private
    attr_reader :iteration_uuid

    def orchestrator_url
      Exercism.config.tooling_orchestrator_url
    end
  end
end
