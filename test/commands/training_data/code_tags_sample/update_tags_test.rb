require 'test_helper'

class TrainingData::CodeTagsSample::UpdateTagsTest < ActiveSupport::TestCase
  test "updates tags when locked by user" do
    user = create :user
    tags = ['construct:if']
    sample = create(:training_data_code_tags_sample, status: :untagged, locked_by: user, locked_until: Time.current + 1.day)

    TrainingData::CodeTagsSample::UpdateTags.(sample, tags, :human_tagged, user)

    assert_equal tags, sample.tags
    refute sample.locked?
  end

  test "updates tags when not locked" do
    user = create :user
    tags = ['construct:if']
    sample = create(:training_data_code_tags_sample, status: :untagged, locked_by: nil, locked_until: nil)

    TrainingData::CodeTagsSample::UpdateTags.(sample, tags, :human_tagged, user)

    assert_equal tags, sample.tags
    refute sample.locked?
  end

  test "updates status" do
    user = create :user
    sample = create(:training_data_code_tags_sample, status: :untagged, locked_by: user, locked_until: Time.current + 1.day)

    TrainingData::CodeTagsSample::UpdateTags.(sample, ['construct:if'], :human_tagged, user)

    assert_equal :human_tagged, sample.status
  end

  test "stores unique tags" do
    user = create :user
    tags = ['construct:if', 'construct:else', 'construct:else', 'construct:if', 'construct:if']
    sample = create(:training_data_code_tags_sample, status: :untagged, locked_by: user, locked_until: Time.current + 1.day)

    TrainingData::CodeTagsSample::UpdateTags.(sample, tags, :human_tagged, user)

    assert_equal ['construct:if', 'construct:else'], sample.tags
  end

  test "gracefully handle nil tags" do
    user = create :user
    tags = nil
    sample = create(:training_data_code_tags_sample, status: :untagged, locked_by: user, locked_until: Time.current + 1.day)

    TrainingData::CodeTagsSample::UpdateTags.(sample, tags, :human_tagged, user)

    assert_nil sample.tags
  end

  test "removes lock" do
    user = create :user
    tags = ['construct:if']
    sample = create(:training_data_code_tags_sample, status: :untagged, locked_by: user, locked_until: Time.current + 1.day)

    # Sanity check
    assert sample.locked?

    TrainingData::CodeTagsSample::UpdateTags.(sample, tags, :human_tagged, user)

    refute sample.locked?
    assert_nil sample.locked_until
    assert_nil sample.locked_by
  end

  test "raises when locked by other user" do
    user = create :user
    lock_user = create :user
    tags = ['construct:if']
    sample = create(:training_data_code_tags_sample, status: :untagged, locked_by: lock_user, locked_until: Time.current + 1.day)

    assert_raises TrainingDataCodeTagsSampleLockedError do
      TrainingData::CodeTagsSample::UpdateTags.(sample, tags, :human_tagged, user)
    end

    assert_nil sample.tags
    assert sample.locked?
    refute_nil sample.locked_until
    assert_equal lock_user, sample.locked_by
  end

  %i[machine_tagged human_tagged].each do |status|
    test "sets community_checked_by to user when current status is #{status}" do
      user = create :user
      tags = ['construct:if']
      sample = create(:training_data_code_tags_sample, status:, locked_by: nil, locked_until: nil)

      TrainingData::CodeTagsSample::UpdateTags.(sample, tags, :human_tagged, user)

      assert_equal user, sample.community_checked_by
      assert_nil sample.admin_checked_by
    end
  end

  test "sets admin_checked_by to user when current status is community_checked" do
    user = create :user
    community_checked_by_user = create :user
    tags = ['construct:if']
    sample = create(:training_data_code_tags_sample, status: :community_checked, community_checked_by: community_checked_by_user,
      locked_by: nil, locked_until: nil)

    TrainingData::CodeTagsSample::UpdateTags.(sample, tags, :admin_checked, user)

    assert_equal user, sample.admin_checked_by
  end

  test "does not change community_checked_by user when setting admin_checked_by user" do
    user = create :user
    community_checked_by_user = create :user
    tags = ['construct:if']
    sample = create(:training_data_code_tags_sample, status: :community_checked, community_checked_by: community_checked_by_user,
      locked_by: nil, locked_until: nil)

    TrainingData::CodeTagsSample::UpdateTags.(sample, tags, :admin_checked, user)

    assert_equal community_checked_by_user, sample.community_checked_by
  end
end
