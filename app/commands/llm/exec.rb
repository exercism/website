class LLM::Exec
  include Mandate

  initialize_with :service, :model, :prompt, :spi_endpoint, :stream_channel

  def call
    raise "Service cannot be nil" if service.nil?
    raise "Model cannot be nil" if model.nil?
    raise "Prompt cannot be nil" if prompt.nil?
    raise "SPI endpoint cannot be nil" if spi_endpoint.nil?

    LLM::ExecWithPayload.(
      {
        service: service,
        model: model,
        spi_endpoint: "llm/#{spi_endpoint}",
        stream_channel: stream_channel,
        prompt: prompt
      }
    )
  end
end
