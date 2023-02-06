class Submission::Analysis::Cancel
  include Mandate

  initialize_with :submission_uuid

  def call
    RestClient.post "#{orchestrator_url}/submissions/cancel", {
      submission_uuid:
    }
  end

  private
  def orchestrator_url
    Exercism.config.tooling_orchestrator_url
  end
end
