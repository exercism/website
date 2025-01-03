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

  test "returns exercise with lowest idx" do
    user = create :user, :with_bootcamp_data
    create :bootcamp_exercise, idx: 2
    exercise = create :bootcamp_exercise, idx: 1
    create :bootcamp_exercise, idx: 3

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

  test "doesn't return completed exercise for user_project" do
    user = create :user, :with_bootcamp_data
    project = create :bootcamp_project
    solved_exercise = create(:bootcamp_exercise, idx: 1, project:)
    exercise = create(:bootcamp_exercise, idx: 2, project:)
    create :bootcamp_user_project, user:, project:, status: :available

    create :bootcamp_solution, :completed, user:, exercise: solved_exercise

    actual = Bootcamp::SelectNextExercise.(user)
    assert_equal exercise, actual
  end

  test "prefers exercise from existing user project" do
    user = create :user, :with_bootcamp_data
    create :bootcamp_exercise, idx: 1
    exercise = create :bootcamp_exercise, idx: 2
    create :bootcamp_user_project, user:, project: exercise.project, status: :available

    actual = Bootcamp::SelectNextExercise.(user)
    assert_equal exercise, actual
  end

  test "doesn't take exercise from locked user project" do
    user = create :user, :with_bootcamp_data
    locked = create :bootcamp_exercise, idx: 1
    exercise = create :bootcamp_exercise, idx: 2
    create :bootcamp_user_project, user:, project: locked.project, status: :locked

    actual = Bootcamp::SelectNextExercise.(user)
    assert_equal exercise, actual
  end

  test "honours passed in project" do
    user = create :user, :with_bootcamp_data
    other = create :bootcamp_exercise, idx: 1
    exercise = create :bootcamp_exercise, idx: 2
    create :bootcamp_user_project, user:, project: other.project, status: :available
    create :bootcamp_user_project, user:, project: exercise.project, status: :available

    actual = Bootcamp::SelectNextExercise.(user, project: exercise.project)
    assert_equal exercise, actual
  end

  test "copes with locked project passed in project" do
    user = create :user, :with_bootcamp_data
    locked = create :bootcamp_exercise, idx: 1
    exercise = create :bootcamp_exercise, idx: 2
    create :bootcamp_user_project, user:, project: locked.project, status: :locked

    actual = Bootcamp::SelectNextExercise.(user, project: locked.project)
    assert_equal exercise, actual
  end
end
