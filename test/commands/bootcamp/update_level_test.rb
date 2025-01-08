require 'test_helper'

class Bootcamp::UpdateUserLevelTest < ActiveSupport::TestCase
  test "sets to 0 with no exercises" do
    user = create :user, :with_bootcamp_data

    Bootcamp::UpdateUserLevel.(user)

    assert_equal 0, user.bootcamp_data.level_idx
  end

  test "sets to 0 with no completed exercises" do
    user = create :user, :with_bootcamp_data
    create :bootcamp_exercise

    Bootcamp::UpdateUserLevel.(user)

    assert_equal 0, user.bootcamp_data.level_idx
  end

  test "sets to level when completed" do
    user = create :user, :with_bootcamp_data
    create :bootcamp_level, idx: 1
    exercise = create :bootcamp_exercise, level_idx: 1
    create(:bootcamp_solution, :completed, user:, exercise:)

    Bootcamp::UpdateUserLevel.(user)

    assert_equal 1, user.bootcamp_data.level_idx
  end

  test "does not set when not all completed" do
    user = create :user, :with_bootcamp_data
    create :bootcamp_level, idx: 1
    create :bootcamp_solution, user:, exercise: create(:bootcamp_exercise, level_idx: 1)
    create :bootcamp_solution, :completed, user:, exercise: create(:bootcamp_exercise, level_idx: 1)

    Bootcamp::UpdateUserLevel.(user)

    assert_equal 0, user.bootcamp_data.level_idx
  end

  test "sets to highest level when multiple completed" do
    user = create :user, :with_bootcamp_data
    create :bootcamp_level, idx: 1
    create :bootcamp_level, idx: 2
    exercise_1 = create :bootcamp_exercise, level_idx: 1
    exercise_2 = create :bootcamp_exercise, level_idx: 2
    create :bootcamp_solution, :completed, user:, exercise: exercise_1
    create :bootcamp_solution, :completed, user:, exercise: exercise_2

    Bootcamp::UpdateUserLevel.(user)

    assert_equal 2, user.bootcamp_data.level_idx
  end

  test "requires consecutive levels" do
    user = create :user, :with_bootcamp_data
    create :bootcamp_level, idx: 1
    create :bootcamp_level, idx: 2
    create :bootcamp_level, idx: 3
    exercise_1 = create :bootcamp_exercise, level_idx: 1
    exercise_2 = create :bootcamp_exercise, level_idx: 2
    exercise_3 = create :bootcamp_exercise, level_idx: 3
    create :bootcamp_solution, :completed, user:, exercise: exercise_1
    create :bootcamp_solution, user:, exercise: exercise_2
    create :bootcamp_solution, :completed, user:, exercise: exercise_3

    Bootcamp::UpdateUserLevel.(user)

    assert_equal 1, user.bootcamp_data.level_idx
  end
end
