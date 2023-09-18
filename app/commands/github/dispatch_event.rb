class Github::DispatchEvent
  include Mandate

  initialize_with :repo, :event_type, :client_payload

  def call = Exercism.octokit_client.post(api_url, body)

  private
  def api_url = "https://api.github.com/repos/exercism/#{repo}/dispatches"
  def body = { event_type:, client_payload: }.to_json
end
