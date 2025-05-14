require 'test_helper'

class Bootcamp::Solution::CreateTest < ActiveSupport::TestCase
  test "works normally" do
    user = create :user, :with_bootcamp_data
    project = create :bootcamp_project
    create :bootcamp_user_project, user:, project:, status: :available
    exercise = create(:bootcamp_exercise, project:)
    exercise.stubs(:stub).returns("Something")

    solution = Bootcamp::Solution::Create.(user, exercise)
    assert solution.persisted?
    assert_equal user, solution.user
    assert_equal exercise, solution.exercise
  end

  test "sets basic code" do
    code = "def foo\nend"

    user = create :user, :with_bootcamp_data
    project = create :bootcamp_project
    create :bootcamp_user_project, user:, project:, status: :available
    exercise = create(:bootcamp_exercise, project:)
    exercise.stubs(:stub).returns(code)
    exercise.stubs(:language).returns("jikiscript")

    solution = Bootcamp::Solution::Create.(user, exercise)
    assert_equal code, solution.code
  end

  test "uses solutions from previous exercises" do
    project_slug = "project-34"
    exercise_1_slug = "part-1"
    exercise_2_slug = "ex-2"

    solution_1_code = "first\nbit"
    solution_2_code = "second\ppart"
    template = "Hello {{EXERCISE:#{project_slug}/#{exercise_1_slug}}} World {{EXERCISE:#{project_slug}/#{exercise_2_slug}}} Yay!"
    expected = "Hello #{solution_1_code} World #{solution_2_code} Yay!"

    user = create :user, :with_bootcamp_data
    project = create :bootcamp_project, slug: project_slug
    create :bootcamp_user_project, user:, project:, status: :available
    exercise_1 = create :bootcamp_exercise, project:, slug: exercise_1_slug
    exercise_2 = create :bootcamp_exercise, project:, slug: exercise_2_slug
    exercise_3 = create(:bootcamp_exercise, project:)
    exercise_3.stubs(:stub).returns(template)

    create :bootcamp_solution, user:, exercise: exercise_1, code: solution_1_code, completed_at: Time.current
    create :bootcamp_solution, user:, exercise: exercise_2, code: solution_2_code, completed_at: Time.current

    solution = Bootcamp::Solution::Create.(user, exercise_3)

    assert_equal expected, solution.code
  end

  test "guards against not available exercises" do
    user = create :user, :with_bootcamp_data
    project = create :bootcamp_project
    create(:bootcamp_user_project, user:, project:)
    exercise = create(:bootcamp_exercise, project:)

    Bootcamp::Exercise::AvailableForUser.expects(:call).with(exercise, user).returns(false)

    assert_raises ExerciseLockedError do
      Bootcamp::Solution::Create.(user, exercise)
    end
  end
end
