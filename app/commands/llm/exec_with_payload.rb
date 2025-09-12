# Don't call this directly unless you're
# dealing with specific LLM retries etc.
# Instead use the LLM::Exec command.
class LLM::ExecWithPayload
  include Mandate

  initialize_with :payload

  def call
    RestClient.post(
      proxy_url,
      payload.to_json,
      { content_type: :json, accept: :json }
    )
  end

  def proxy_url = "http://localhost:8080/exec"
end
