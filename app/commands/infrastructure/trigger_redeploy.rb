class Infrastructure::TriggerRedeploy
  include Mandate

  def call = Github::DispatchWorkflow.("website-deployer", "deploy.yml")
end
