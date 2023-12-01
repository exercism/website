require 'test_helper'

class TrainingData::CodeTagsSample::GenerateTagsTest < ActiveSupport::TestCase
  test "update tags from openai when safe to override?" do
    openai_key = 'openai_key'
    model = Exercism.secrets.openai_tags_model

    Exercism.stubs(:openai_client).returns(OpenAI::Client.new(access_token: openai_key))

    tags = ['construct:if', 'paradigm:functional']

    stub_request(:post, "https://api.openai.com/v1/chat/completions").
      with(
        body: {
          model:,
          messages: [
            { role: "system", content: "You are a expert in EXERCISM_REPRESENTATION_TAGS" },
            { role: "user", content: "Respond with a JSON object containing one top-level key called tags containing an array of EXERCISM_REPRESENTATION_TAGS (programming concepts, paradigms and techniques) for this Ruby code:\n\n---\n\n```\nHello, World!\n```" } # rubocop:disable Layout/LineLength
          ],
          temperature: 0.1
        }.to_json,
        headers: {
          'Authorization' => "Bearer #{openai_key}",
          'Content-Type' => 'application/json'
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

    TrainingData::CodeTagsSample::GenerateTags.(sample)

    assert_equal tags, sample.tags
    assert_equal tags, sample.llm_tags
    assert_equal :machine_tagged, sample.status
  end

  test "does not update tags when not safe to override?" do
    updated_at = Time.current - 1.week
    sample = create(:training_data_code_tags_sample, status: :human_tagged, updated_at:)

    TrainingData::CodeTagsSample::GenerateTags.(sample)

    assert_equal updated_at, sample.updated_at
  end
end
