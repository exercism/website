require 'test_helper'

class TrainingData::CodeTagsSample::GenerateTagsTest < ActiveSupport::TestCase
  test "update tags from openai when safe to override?" do
    model = 'exercism_tags'
    openai_key = 'openai_key'
    tags = ['construct:if', 'paradigm:functional']

    stub_request(:post, "https://api.openai.com/v1/chat/completions").
      with(
        body: {
          model:,
          messages: [
            {
              role: "system",
              content: "You are a expert in EXERCISM_REPRESENTATION_TAGS"
            },
            {
              role: "user",
              content: "In JSON, list the set of programming concepts, paradigms and techniques as EXERCISM_REPRESENTATION_TAGS for this Ruby code:\n\n---\n\nHello, World!" # rubocop:disable Layout/LineLength
            }
          ],
          temperature: 0.2
        }.to_json,
        headers: {
          'Authorization': "Bearer #{openai_key}",
          'Content-Type': 'application/json'
        }
      ).
      to_return(
        status: 200,
        body: {
          choices: [
            { message: { content: tags } }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    sample = create(:training_data_code_tags_sample, status: :untagged)

    TrainingData::CodeTagsSample::GenerateTags.(sample, model, openai_key)

    assert_equal tags, sample.tags
    assert_equal tags, sample.llm_tags
    assert_equal :machine_tagged, sample.status
  end

  test "does not update tags when not safe to override?" do
    updated_at = Time.current - 1.week
    sample = create(:training_data_code_tags_sample, status: :human_tagged, updated_at:)

    TrainingData::CodeTagsSample::GenerateTags.(sample, 'exercism_tags', 'openai_key')

    assert_equal updated_at, sample.updated_at
  end
end
