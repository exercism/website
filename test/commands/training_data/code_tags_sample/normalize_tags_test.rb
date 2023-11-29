require 'test_helper'

class TrainingData::CodeTagsSample::NormalizeTagsTest < ActiveSupport::TestCase
  test "deduplicates tags" do
    tags = ['construct:if', 'construct:loop', 'construct:loop', 'construct:if', 'construct:if']
    normalized_tags = TrainingData::CodeTagsSample::NormalizeTags.(tags)
    assert_equal ['construct:if', 'construct:loop'], normalized_tags
  end

  test "normalizes tags" do
    assert_equal ['construct:global-variable'], TrainingData::CodeTagsSample::NormalizeTags.(['construct:global-variables'])
    assert_equal ['construct:if', 'construct:else'], TrainingData::CodeTagsSample::NormalizeTags.(['construct:if-then-else'])
    assert_empty TrainingData::CodeTagsSample::NormalizeTags.(['construct:positional-parameter'])
  end

  test "gracefully handles nil tags" do
    tags = nil
    assert_nil TrainingData::CodeTagsSample::NormalizeTags.(tags)
  end
end
