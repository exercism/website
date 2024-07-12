class Github::DispatchWorkflow
  include Mandate

  initialize_with :repo, :workflow_id

  def call = Exercism.octokit_client.post(api_url, body)

  private
  def api_url = "https://api.github.com/repos/exercism/#{repo}/actions/workflows/#{workflow_id}/dispatches"
  def body = { ref: "main" }.to_json
end
