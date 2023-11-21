require "test_helper"

class Exercise::UpdateTagsTest < ActiveSupport::TestCase
  test "update tags" do
    exercise = create :practice_exercise
    other_exercise = create :practice_exercise

    # No solution tag
    existing_tag_to_remove = create(:exercise_tag, tag: 'uses:date.add_days', exercise:)

    # Passing, published solution
    existing_tag_to_keep = create(:exercise_tag, tag: 'construct:exception', exercise:)
    solution = create(:practice_solution, :published, exercise:, published_iteration_head_tests_status: :passed)
    solution_tag_to_keep = create(:solution_tag, tag: existing_tag_to_keep.tag, exercise:, solution:)

    # Also passing, published solution
    solution = create(:practice_solution, :published, exercise:, published_iteration_head_tests_status: :passed)
    solution_tag_to_add = create(:solution_tag, tag: 'paradigm:object-oriented', exercise:, solution:)

    # Unpublished solution
    solution = create(:practice_solution, exercise:, published_iteration_head_tests_status: :passed)
    unpublished_exercise_tag = create(:exercise_tag, tag: 'construct:unpublished', exercise:)
    create(:solution_tag, tag: unpublished_exercise_tag.tag, exercise:, solution:)

    # Failing solution
    solution = create(:practice_solution, :published, exercise:, published_iteration_head_tests_status: :failed)
    failing_exercise_tag = create(:exercise_tag, tag: 'construct:failure', exercise:)
    create(:solution_tag, tag: failing_exercise_tag.tag, exercise:, solution:)

    # Sanity check: tag should still be remove as this is linked to another exercise
    create(:solution_tag, tag: existing_tag_to_remove.tag, exercise: other_exercise)

    old_tags = [existing_tag_to_remove.tag, existing_tag_to_keep.tag, unpublished_exercise_tag.tag, failing_exercise_tag.tag]
    assert_equal old_tags, exercise.reload.tags.order(:id).pluck(:tag)

    Exercise::UpdateTags.(exercise)

    assert_equal [solution_tag_to_keep.tag, solution_tag_to_add.tag], exercise.reload.tags.order(:id).pluck(:tag)
    assert_raises ActiveRecord::RecordNotFound, &proc { existing_tag_to_remove.reload }
  end

  test "update track tags" do
    exercise = create :practice_exercise

    Track::UpdateTags.expects(:call).with(exercise.track)

    Exercise::UpdateTags.(exercise)
  end
end
