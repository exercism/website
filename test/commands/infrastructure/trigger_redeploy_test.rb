require "test_helper"

class Infrastructure::TriggerRedeployTest < ActiveSupport::TestCase
  test "calls GHA deploy workflow" do
    Github::DispatchWorkflow.expects(:call).with("website", "deploy.yml")

    Infrastructure::TriggerRedeploy.()
  end
end
