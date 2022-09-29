require "test_helper"

class Exercise::UpdateHasApproachesTest < ActiveSupport::TestCase
  test "has_approaches set to true when the exercise has at least one community video" do
    exercise = create :practice_exercise

    # Sanity check
    refute exercise.reload.has_approaches?
    
    create :community_video, exercise: exercise

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

  test "has_approaches set to false when the exercise does not have an approaches introduction nor community videos" do
    exercise = create :practice_exercise, slug: 'leap'

    # Sanity check
    refute exercise.reload.has_approaches?
  
    Exercise::UpdateHasApproaches.(exercise)

    refute exercise.reload.has_approaches?
  end
end
