require 'test_helper'

class Bootcamp::UpdateUserLevelTest < ActiveSupport::TestCase
  test "sets to 1 with no exercises (p1)" do
    user = create :user, :with_bootcamp_data

    Bootcamp::UpdateUserLevel.(user, 1)

    assert_equal 1, user.bootcamp_data.part_1_level_idx
  end

  test "sets to 11 with no exercises (p2)" do
    user = create :user, :with_bootcamp_data

    Bootcamp::UpdateUserLevel.(user, 2)

    assert_equal 11, user.bootcamp_data.part_2_level_idx
  end

  test "sets to 1 with no completed exercises" do
    user = create :user, :with_bootcamp_data
    create :bootcamp_exercise

    Bootcamp::UpdateUserLevel.(user, 1)

    assert_equal 1, user.bootcamp_data.level_idx
  end

  test "sets to next level when completed" do
    user = create :user, :with_bootcamp_data
    [1, 2].each { |idx| create :bootcamp_level, idx: }
    exercise = create :bootcamp_exercise, level_idx: 1
    create(:bootcamp_solution, :completed, user:, exercise:)

    Bootcamp::UpdateUserLevel.(user, 1)

    assert_equal 2, user.bootcamp_data.level_idx
  end

  test "ignores non-blockers " do
    user = create :user, :with_bootcamp_data
    [1, 2].each { |idx| create :bootcamp_level, idx: }
    exercise = create :bootcamp_exercise, level_idx: 1
    create :bootcamp_exercise, level_idx: 1, blocks_level_progression: false
    create(:bootcamp_solution, :completed, user:, exercise:)

    Bootcamp::UpdateUserLevel.(user, 1)

    assert_equal 2, user.bootcamp_data.level_idx
  end

  test "sets to current level when not all completed" do
    user = create :user, :with_bootcamp_data
    create :bootcamp_level, idx: 1
    create :bootcamp_solution, user:, exercise: create(:bootcamp_exercise, level_idx: 1)
    create :bootcamp_solution, :completed, user:, exercise: create(:bootcamp_exercise, level_idx: 1)

    Bootcamp::UpdateUserLevel.(user, 1)

    assert_equal 1, user.bootcamp_data.level_idx
  end

  test "sets to next possible level when multiple completed" do
    user = create :user, :with_bootcamp_data
    [1, 2].each { |idx| create :bootcamp_level, idx: }
    exercise_1 = create :bootcamp_exercise, level_idx: 1
    exercise_2 = create :bootcamp_exercise, level_idx: 2
    create :bootcamp_solution, :completed, user:, exercise: exercise_1
    create :bootcamp_solution, :completed, user:, exercise: exercise_2

    Bootcamp::UpdateUserLevel.(user, 1)

    assert_equal 3, user.bootcamp_data.level_idx
  end

  test "requires consecutive levels" do
    user = create :user, :with_bootcamp_data
    [1, 2, 3].each { |idx| create :bootcamp_level, idx: }
    exercise_1 = create :bootcamp_exercise, level_idx: 1
    exercise_2 = create :bootcamp_exercise, level_idx: 2
    exercise_3 = create :bootcamp_exercise, level_idx: 3
    create :bootcamp_solution, :completed, user:, exercise: exercise_1
    create :bootcamp_solution, user:, exercise: exercise_2
    create :bootcamp_solution, :completed, user:, exercise: exercise_3

    Bootcamp::UpdateUserLevel.(user, 1)

    assert_equal 2, user.bootcamp_data.level_idx
  end

  test "doesn't let user go backwards" do
    initial_level_idx = 3
    [1, 2, 3].each { |idx| create :bootcamp_level, idx: }
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update(part_1_level_idx: initial_level_idx)

    exercise = create :bootcamp_exercise, level_idx: 1
    create(:bootcamp_solution, :completed, user:, exercise:)

    Bootcamp::UpdateUserLevel.(user, 1)

    assert_equal initial_level_idx, user.bootcamp_data.level_idx
  end

  test "doesn't affect part 1 if part 2 is chosen" do
    (1..20).each { |idx| create :bootcamp_level, idx: }
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update(part_1_level_idx: 3, part_2_level_idx: 13)

    exercise = create :bootcamp_exercise, level_idx: 15
    create(:bootcamp_solution, :completed, user:, exercise:)

    Bootcamp::UpdateUserLevel.(user, 2)

    assert_equal 3, user.bootcamp_data.part_1_level_idx
    assert_equal 16, user.bootcamp_data.part_2_level_idx
  end

  test "doesn't affect part 2 if part 1 is chosen" do
    (1..20).each { |idx| create :bootcamp_level, idx: }
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update(part_1_level_idx: 3, part_2_level_idx: 13)

    exercise = create :bootcamp_exercise, level_idx: 3
    create(:bootcamp_solution, :completed, user:, exercise:)

    Bootcamp::UpdateUserLevel.(user, 1)

    assert_equal 4, user.bootcamp_data.part_1_level_idx
    assert_equal 13, user.bootcamp_data.part_2_level_idx
  end
end
