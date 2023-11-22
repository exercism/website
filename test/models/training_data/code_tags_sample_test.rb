require 'test_helper'

class TrainingData::CodeTagsSampleTest < ActiveSupport::TestCase
  test "llm_tags: inferred from tags when creating a new record" do
    sample = create(:training_data_code_tags_sample, tags: nil)
    assert_nil sample.tags
    assert_nil sample.llm_tags

    tags = '["construct:if"]'
    sample = create(:training_data_code_tags_sample, tags:)
    assert_equal tags, sample.tags
    assert_equal tags, sample.llm_tags
  end

  test "llm_tags: not changed when tags are updated" do
    original_tags = '["construct:if"]'
    sample = create(:training_data_code_tags_sample, tags: original_tags)
    assert_equal original_tags, sample.tags
    assert_equal original_tags, sample.llm_tags

    new_tags = '["construct:if", "paradigm:functional"]'
    sample.update(tags: new_tags)
    assert_equal new_tags, sample.tags
    assert_equal original_tags, sample.llm_tags
  end
end
