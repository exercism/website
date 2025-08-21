require "test_helper"

class Github::DispatchWorkflowTest < ActiveJob::TestCase
  test "dispatch workflow" do
    stub_request(:post, "https://api.github.com/repos/exercism/ruby/actions/workflows/configlet.yml/dispatches").
      with(body: '{"ref":"main"}')

    Github::DispatchWorkflow.("ruby", "configlet.yml")
  end

  test "custom ref" do
    ref = 'my-branch'
    stub_request(:post, "https://api.github.com/repos/exercism/ruby/actions/workflows/deploy.yml/dispatches").
      with(body: '{"ref":"my-branch"}')

    Github::DispatchWorkflow.("ruby", "deploy.yml", ref:)
  end
end
