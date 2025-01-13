require 'test_helper'

class Bootcamp::SelectNextExerciseTest < ActiveSupport::TestCase
  def setup
    super

    Bootcamp::Settings.instance.update(level_idx: 10)
  end

  test "returns exercise" do
    user = create :user, :with_bootcamp_data
    exercise = create :bootcamp_exercise

    actual = Bootcamp::SelectNextExercise.(user)
    assert_equal exercise, actual
  end

  test "returns exercise with lowest level and idx pair" do
    (1..3).each { |idx| create :bootcamp_level, idx: }
    user = create :user, :with_bootcamp_data
    create :bootcamp_exercise, level_idx: 2, idx: 2
    create :bootcamp_exercise, level_idx: 2, idx: 1
    create :bootcamp_exercise, level_idx: 1, idx: 2
    exercise = create :bootcamp_exercise, level_idx: 1, idx: 1
    create :bootcamp_exercise, level_idx: 1, idx: 3
    create :bootcamp_exercise, level_idx: 3, idx: 2
    create :bootcamp_exercise, level_idx: 3, idx: 1

    actual = Bootcamp::SelectNextExercise.(user)
    assert_equal exercise, actual
  end

  test "doesn't return completed exercise" do
    user = create :user, :with_bootcamp_data
    project = create :bootcamp_project
    solved_exercise = create(:bootcamp_exercise, idx: 1, project:)
    exercise = create(:bootcamp_exercise, idx: 2, project:)

    create :bootcamp_solution, user:, exercise: solved_exercise, completed_at: Time.current

    actual = Bootcamp::SelectNextExercise.(user)
    assert_equal exercise, actual
  end
end
