class LLM::ExecGeminiFlash
  include Mandate

  initialize_with :prompt, :spi_endpoint, stream_channel: nil

  def call
    LLM::Exec.(:gemini, :flash, prompt, spi_endpoint, stream_channel)
  end
end
