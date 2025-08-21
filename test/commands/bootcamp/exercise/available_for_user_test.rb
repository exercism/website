require 'test_helper'

class Bootcamp::Exercise::AvailableForUserTest < ActiveSupport::TestCase
  test "return true if first exercise" do
    create :bootcamp_level, idx: 1
    exercise = create :bootcamp_exercise, level_idx: 1
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update!(part_1_level_idx: 10)

    Bootcamp::Settings.instance.update(level_idx: 1)

    assert Bootcamp::Exercise::AvailableForUser.(exercise, user)
  end

  test "return false if level not reached" do
    (1..2).each { |idx| create :bootcamp_level, idx: }
    exercise = create :bootcamp_exercise, level_idx: 2
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update!(part_1_level_idx: 10)

    Bootcamp::Settings.instance.update(level_idx: 1)

    refute Bootcamp::Exercise::AvailableForUser.(exercise, user)
  end

  test "return false if previous exercise not started" do
    create :bootcamp_level, idx: 1
    project = create :bootcamp_project
    create(:bootcamp_exercise, level_idx: 1, idx: 1, project:)
    second_exercise = create(:bootcamp_exercise, level_idx: 1, idx: 2, project:)
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update!(part_1_level_idx: 10)

    Bootcamp::Settings.instance.update(level_idx: 1)

    refute Bootcamp::Exercise::AvailableForUser.(second_exercise, user)
  end

  test "return false if previous exercise not completed" do
    create :bootcamp_level, idx: 1
    project = create :bootcamp_project
    first_exercise = create(:bootcamp_exercise, level_idx: 1, idx: 1, project:)
    second_exercise = create(:bootcamp_exercise, level_idx: 1, idx: 2, project:)
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update!(part_1_level_idx: 10)
    create(:bootcamp_solution, exercise: first_exercise, user:)

    Bootcamp::Settings.instance.update(level_idx: 1)

    refute Bootcamp::Exercise::AvailableForUser.(second_exercise, user)
  end

  test "return true if previous exercise completed" do
    create :bootcamp_level, idx: 1
    project = create :bootcamp_project
    first_exercise = create(:bootcamp_exercise, level_idx: 1, idx: 1, project:)
    second_exercise = create(:bootcamp_exercise, level_idx: 1, idx: 2, project:)
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update!(part_1_level_idx: 10)
    create(:bootcamp_solution, :completed, exercise: first_exercise, user:)

    Bootcamp::Settings.instance.update(level_idx: 1)

    assert Bootcamp::Exercise::AvailableForUser.(second_exercise, user)
  end

  test "ignores blocks_level_progression: false" do
    create :bootcamp_level, idx: 1
    project = create :bootcamp_project
    first_exercise = create(:bootcamp_exercise, level_idx: 1, idx: 1, project:)
    second_exercise = create(:bootcamp_exercise, level_idx: 1, idx: 2, project:, blocks_project_progression: false)
    third_exercise = create(:bootcamp_exercise, level_idx: 1, idx: 3, project:)
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update!(part_1_level_idx: 10)
    create(:bootcamp_solution, :completed, exercise: first_exercise, user:)

    Bootcamp::Settings.instance.update(level_idx: 1)

    assert Bootcamp::Exercise::AvailableForUser.(second_exercise, user)
    assert Bootcamp::Exercise::AvailableForUser.(third_exercise, user)
  end

  test "return false if previous level exercise not started" do
    (1..2).each { |idx| create :bootcamp_level, idx: }
    project = create :bootcamp_project
    create(:bootcamp_exercise, level_idx: 1, idx: 2, project:)
    second_exercise = create(:bootcamp_exercise, level_idx: 2, idx: 1, project:)
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update!(part_1_level_idx: 10)

    Bootcamp::Settings.instance.update(level_idx: 2)

    refute Bootcamp::Exercise::AvailableForUser.(second_exercise, user)
  end

  test "return false if previous level exercise not completed" do
    (1..2).each { |idx| create :bootcamp_level, idx: }
    project = create :bootcamp_project
    first_exercise = create(:bootcamp_exercise, level_idx: 1, idx: 2, project:)
    second_exercise = create(:bootcamp_exercise, level_idx: 2, idx: 1, project:)
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update!(part_1_level_idx: 10)
    create(:bootcamp_solution, exercise: first_exercise, user:)

    Bootcamp::Settings.instance.update(level_idx: 2)

    refute Bootcamp::Exercise::AvailableForUser.(second_exercise, user)
  end

  test "return true if previous level exercise completed" do
    (1..2).each { |idx| create :bootcamp_level, idx: }
    project = create :bootcamp_project
    first_exercise = create(:bootcamp_exercise, level_idx: 1, idx: 2, project:)
    second_exercise = create(:bootcamp_exercise, level_idx: 2, idx: 1, project:)
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update!(part_1_level_idx: 10)
    create(:bootcamp_solution, :completed, exercise: first_exercise, user:)

    Bootcamp::Settings.instance.update(level_idx: 2)

    assert Bootcamp::Exercise::AvailableForUser.(second_exercise, user)
  end

  test "return false if user's level isn't at this level yet" do
    Bootcamp::Settings.instance.update(level_idx: 2)

    (1..2).each { |idx| create :bootcamp_level, idx: }
    exercise = create :bootcamp_exercise, level_idx: 2
    user = create :user, :with_bootcamp_data
    user.bootcamp_data.update!(part_1_level_idx: 1)

    refute Bootcamp::Exercise::AvailableForUser.(exercise, user)
  end
end
