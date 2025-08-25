class LLM::Exec
  include Mandate

  initialize_with :service, :model, :prompt, :spi_endpoint, :stream_channel

  def call
    raise "Service cannot be nil" if service.nil?
    raise "Model cannot be nil" if model.nil?
    raise "Prompt cannot be nil" if prompt.nil?
    raise "SPI endpoint cannot be nil" if spi_endpoint.nil?

    RestClient.post(
      proxy_url,
      {
        service: service,
        model: model,
        spi_endpoint: "llm_responses/#{spi_endpoint}",
        stream_channel: stream_channel,
        prompt: prompt
      }.to_json,
      { content_type: :json, accept: :json }
    )
  end

  def proxy_url = "http://localhost:8080/exec"
end
