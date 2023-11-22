require 'test_helper'

class TrainingData::CodeTagsSampleTest < ActiveSupport::TestCase
  test "llm_tags: not changed when tags are updated" do
    original_tags = '["construct:if"]'
    sample = create(:training_data_code_tags_sample, tags: original_tags, llm_tags: original_tags)
    assert_equal original_tags, sample.tags
    assert_equal original_tags, sample.llm_tags

    new_tags = '["construct:if", "paradigm:functional"]'
    sample.update(tags: new_tags)
    assert_equal new_tags, sample.tags
    assert_equal original_tags, sample.llm_tags
  end

  %i[human_tagged community_checked admin_checked].each do |status|
    test "safe_to_override? is false when status is #{status}" do
      sample = create(:training_data_code_tags_sample, status:)
      refute sample.safe_to_override?
    end
  end

  %i[untagged machine_tagged].each do |status|
    test "safe_to_override? is true when status is #{status}" do
      sample = create(:training_data_code_tags_sample, status:)
      assert sample.safe_to_override?
    end
  end
end
