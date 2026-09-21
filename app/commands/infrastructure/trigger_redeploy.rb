class Infrastructure::TriggerRedeploy
  include Mandate

  def call = Github::DispatchWorkflow.("website", "deploy.yml")
end
