require 'test_helper'

class TrainingData::CodeTagsSample::RetrieveNextTest < ActiveSupport::TestCase
  test "returns first unlocked sample for specified track and filter status" do
    track = create :track, :random_slug
    other_track = create :track, :random_slug

    assert_nil TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_tagging)
    assert_nil TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_checking)
    assert_nil TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_checking_admin)

    # Sanity check: these should not match due to them being linked to a different track
    create(:training_data_code_tags_sample, status: :untagged, track: other_track)
    create(:training_data_code_tags_sample, status: :machine_tagged, track: other_track)

    untagged = create(:training_data_code_tags_sample, status: :untagged, track:)
    machine_tagged = create(:training_data_code_tags_sample, status: :machine_tagged, track:)

    assert_equal untagged, TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_tagging)
    assert_equal machine_tagged, TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_checking)
    assert_nil TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_checking_admin)

    human_tagged = create(:training_data_code_tags_sample, status: :human_tagged, track:)
    community_checked = create(:training_data_code_tags_sample, status: :community_checked, track:)
    create(:training_data_code_tags_sample, status: :admin_checked, track:)

    assert_equal untagged, TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_tagging)
    assert_equal machine_tagged, TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_checking)
    assert_equal community_checked, TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_checking_admin)

    machine_tagged.update(status: :community_checked)
    assert_equal untagged, TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_tagging)
    assert_equal human_tagged, TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_checking)
    assert_equal machine_tagged, TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_checking_admin)

    untagged.update(locked_until: Time.current + 1.day)
    human_tagged.update(locked_until: Time.current - 5.hours)
    machine_tagged.update(locked_until: nil)
    assert_nil TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_tagging)
    assert_equal human_tagged, TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_checking)
    assert_equal machine_tagged, TrainingData::CodeTagsSample::RetrieveNext.(track, :needs_checking_admin)
  end
end
