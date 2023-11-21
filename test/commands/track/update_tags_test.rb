require "test_helper"

class Track::UpdateTagsTest < ActiveSupport::TestCase
  test "update tags" do
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    exercise = create(:practice_exercise, track:)
    other_exercise = create(:practice_exercise, track: other_track)

    existing_tag_to_remove = create(:track_tag, tag: 'uses:date.add_days', track:)
    existing_tag_to_keep = create(:track_tag, tag: 'construct:exception', track:)

    create(:exercise_tag, tag: existing_tag_to_keep.tag, exercise:)

    # Sanity check: tag should still be removed as this is linked to another track
    create(:exercise_tag, tag: existing_tag_to_remove.tag, exercise: other_exercise)

    new_tag_to_add = create(:exercise_tag, tag: 'paradim:logical', exercise:)
    create(:exercise_tag, tag: 'paradim:functional', exercise: other_exercise)

    old_tags = [existing_tag_to_remove.tag, existing_tag_to_keep.tag]
    assert_equal old_tags, track.reload.analyzer_tags.order(:id).pluck(:tag)

    Track::UpdateTags.(track)

    assert_equal [existing_tag_to_keep.tag, new_tag_to_add.tag], track.reload.analyzer_tags.order(:id).pluck(:tag)
    assert_raises ActiveRecord::RecordNotFound, &proc { existing_tag_to_remove.reload }
  end
end
