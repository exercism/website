class TrainingData::CodeTagsSample::GenerateTags
  include Mandate

  queue_as :background

  initialize_with :sample

  def call
    return unless sample.safe_to_override?

    sample.update(tags:, llm_tags: tags, status: :machine_tagged)
  end

  private
  memoize
  def tags
    response = client.chat(
      parameters: {
        model: Exercism.secrets.openai_tags_model,
        messages:,
        temperature: 0.1
      }
    )
    JSON.parse(response.dig("choices", 0, "message", "content"))
  end

  memoize
  def messages
    [
      { "role": "system", "content": SYSTEM_MESSAGE },
      { "role": "user", "content": INSTRUCTION % { lang: sample.track.title, code: sample.files.to_a.pluck("code").join("\n") } }
    ]
  end

  memoize
  def client = Exercism.openai_client

  # rubocop:disable Layout/LineLength
  SYSTEM_MESSAGE = "You are a expert in EXERCISM_REPRESENTATION_TAGS".freeze
  INSTRUCTION = "Respond with a JSON object containing one top-level key called tags containing an array of EXERCISM_REPRESENTATION_TAGS (programming concepts, paradigms and techniques) for this %<lang>s code:\n\n---\n\n```\n%<code>s\n```".freeze
  # rubocop:enable Layout/LineLength
end
