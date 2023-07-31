require "test_helper"

class Exercise::UpdateHasApproachesTest < ActiveSupport::TestCase
  test "has_approaches set to true when the exercise has at least one approved community video" do
    exercise = create :practice_exercise, slug: 'leap'

    Exercise::UpdateHasApproaches.(exercise)

    # Sanity check
    refute exercise.reload.has_approaches?

    # Non-approved videos don't count
    create :community_video, exercise:, watch_id: 'abc', status: :pending
    create :community_video, exercise:, watch_id: 'bdef', status: :rejected

    Exercise::UpdateHasApproaches.(exercise)

    refute exercise.reload.has_approaches?

    create :community_video, exercise:, status: :approved

    Exercise::UpdateHasApproaches.(exercise)

    assert exercise.reload.has_approaches?
  end

  test "has_approaches set to true when the exercise has an approaches introduction" do
    exercise = create :practice_exercise, slug: 'bob'

    # Sanity check
    refute exercise.reload.has_approaches?

    Exercise::UpdateHasApproaches.(exercise)

    assert exercise.reload.has_approaches?
  end

  test "has_approaches set to true when the exercise has an approach" do
    exercise = create :practice_exercise, slug: 'leap'
    create(:exercise_approach, exercise:)

    # Sanity check
    refute exercise.reload.has_approaches?

    Exercise::UpdateHasApproaches.(exercise)

    assert exercise.reload.has_approaches?
  end

  test "has_approaches set to true when the exercise has an article" do
    exercise = create :practice_exercise, slug: 'leap'
    create(:exercise_article, exercise:)

    # Sanity check
    refute exercise.reload.has_approaches?

    Exercise::UpdateHasApproaches.(exercise)

    assert exercise.reload.has_approaches?
  end

  test "has_approaches set to false when the exercise does not have an approaches introduction nor an approved community videos" do
    exercise = create :practice_exercise, slug: 'leap'

    # Sanity check
    refute exercise.reload.has_approaches?

    Exercise::UpdateHasApproaches.(exercise)

    refute exercise.reload.has_approaches?
  end
end
