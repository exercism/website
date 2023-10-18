require "test_helper"

class Exercise::UpdateTagsTest < ActiveSupport::TestCase
  test "update tags" do
    exercise = create :practice_exercise
    other_exercise = create :practice_exercise
    existing_tag_to_remove = create(:exercise_tag, tag: 'uses:date.add_days', exercise:)
    existing_tag_to_keep = create(:exercise_tag, tag: 'construct:exception', exercise:)
    solution_tag_to_keep = create(:solution_tag, tag: existing_tag_to_keep.tag, exercise:)
    solution_tag_to_add = create(:solution_tag, tag: 'paradigm:object-oriented', exercise:)

    # Sanity check: tag should still be remove as this is linked to another exercise
    create(:solution_tag, tag: existing_tag_to_remove.tag, exercise: other_exercise)

    assert_equal [existing_tag_to_remove.tag, existing_tag_to_keep.tag], exercise.reload.tags.order(:id).pluck(:tag)

    Exercise::UpdateTags.(exercise)

    assert_equal [solution_tag_to_keep.tag, solution_tag_to_add.tag], exercise.reload.tags.order(:id).pluck(:tag)
    assert_raises ActiveRecord::RecordNotFound, &proc { existing_tag_to_remove.reload }
  end
end
