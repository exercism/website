require 'test_helper'

class TrainingData::CodeTagsSample::NormalizeTagsTest < ActiveSupport::TestCase
  test "deduplicates tags" do
    tags = ['construct:if', 'construct:else', 'construct:else', 'construct:if', 'construct:if']
    normalized_tags = TrainingData::CodeTagsSample::NormalizeTags.(tags)
    assert_equal ['construct:if', 'construct:else'], normalized_tags
  end

  test "gracefully handles nil tags" do
    tags = nil
    assert_nil TrainingData::CodeTagsSample::NormalizeTags.(tags)
  end
end
