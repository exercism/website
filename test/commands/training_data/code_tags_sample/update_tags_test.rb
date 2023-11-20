require 'test_helper'

class TrainingData::CodeTagsSample::UpdatesTest < ActiveSupport::TestCase
  test "updates tags" do
    user = create :user
    tags = ['construct:if']
    sample = create(:training_data_code_tags_sample, status: :untagged, locked_by: user, locked_until: Time.current + 1.day)

    TrainingData::CodeTagsSample::UpdateTags.(sample, tags, user)

    assert_equal tags, sample.tags
  end

  [
    %i[untagged human_tagged],
    %i[machine_tagged community_checked],
    %i[human_tagged community_checked],
    %i[community_checked admin_checked]
  ].each do |(from_status, to_status)|
    test "updates status from #{from_status} to #{to_status}" do
      user = create :user
      sample = create(:training_data_code_tags_sample, status: from_status, locked_by: user, locked_until: Time.current + 1.day)

      TrainingData::CodeTagsSample::UpdateTags.(sample, ['construct:if'], user)

      assert_equal to_status, sample.status
    end
  end

  test "removes lock" do
    user = create :user
    tags = ['construct:if']
    sample = create(:training_data_code_tags_sample, status: :untagged, locked_by: user, locked_until: Time.current + 1.day)

    # Sanity check
    assert sample.locked?

    TrainingData::CodeTagsSample::UpdateTags.(sample, tags, user)

    refute sample.locked?
    assert_nil sample.locked_until
    assert_nil sample.locked_by
  end

  test "raises when locked by other user" do
    user = create :user
    lock_user = create :user
    tags = ['construct:if']
    sample = create(:training_data_code_tags_sample, status: :untagged, locked_by: lock_user, locked_until: Time.current + 1.day)

    assert_raises TrainingDataCodeTagsSampleLockedByAnotherUserError do
      TrainingData::CodeTagsSample::UpdateTags.(sample, tags, user)
    end
  end
end
