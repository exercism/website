class Bootcamp::ChatMessage
  class TriggerLLM
    include Mandate
    initialize_with :source_message

    def call
      RestClient.post(
        ENV.fetch("GEMINI_STREAMER_URL", "http://localhost:8080/chat"),
        {
          user_id: user.id,
          solution_id: solution.id,
          prompt:,
          stream_channel:
        }.to_json,
        { content_type: :json }
      )
    end

    delegate :solution, :user, :content, to: :source_message

    def stream_channel = "chat_#{user.id}"

    def prompt
      content
    end
  end
end
