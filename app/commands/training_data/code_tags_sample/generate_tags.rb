class TrainingData::CodeTagsSample::GenerateTags
  include Mandate

  initialize_with :sample, :model, :openai_key

  def call
    return if sample.safe_to_override?

    sample.update(tags:, llm_tags: tags, status: :machine_tagged)
  end

  private
  memoize
  def tags
    output = RestClient.post(
      "https://api.openai.com/v1/chat/completions",
      {
        model:,
        messages:,
        temperature: 0.2
      }.to_json,
      {
        Authorization: "Bearer #{openai_key}",
        content_type: :json, accept: :json
      }
    )
    content = JSON.parse(output)['choices'][0]['message']['content']
    JSON.parse(content)
  end

  memoize
  def messages
    [
      { "role": "system", "content": SYSTEM_MESSAGE },
      { "role": "user", "content": INSTRUCTION % { lang: sample.track.title, code: sample.code } }
    ]
  end

  # rubocop:disable Layout/LineLength
  SYSTEM_MESSAGE = "You are a expert in EXERCISM_REPRESENTATION_TAGS".freeze
  INSTRUCTION = "In JSON, list the set of programming concepts, paradigms and techniques as EXERCISM_REPRESENTATION_TAGS for this %<lang>s code:\n\n---\n\n%<code>s".freeze
  # rubocop:enable Layout/LineLength
end
