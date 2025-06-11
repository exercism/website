class Bootcamp::ChatMessage
  class TriggerLLM
    include Mandate

    initialize_with :solution

    def call
      RestClient.post(
        ENV.fetch("GEMINI_STREAMER_URL", "http://localhost:8080/chat"),
        {
          solution_uuid: solution.uuid,
          exercise_info:,
          code:,
          messages:,
          stream_channel:
        }.to_json,
        { content_type: :json }
      )
    end

    def stream_channel = "bootcamp_chat_#{solution.uuid}"

    def exercise_info
      <<~EOS
        The role of the student is to create a simple snake game in HTML, CSS, and JavaScript.
        The result should be that the snake appears on the screen and moves.
        When it gets near the edge, it should change direction (in a clockwise manner).
        There are no controls or dots to grow yet.

        These are the instructions the student was given:
        `````
          #{solution.exercise.introduction_markdown}
        `````
      EOS
    end

    def messages
      solution.messages.last(10).map do |message|
        {
          author: message.author,
          content: message.content
        }
      end
    end

    def code
      code = JSON.parse(solution.code, symbolize_names: true)

      <<~EOS
        ### HTML
        #{code[:html] || ""}

        ### CSS
        #{code[:css] || ""}

        ### JavaScript
        #{code[:js] || ""}
      EOS
    end
  end
end
