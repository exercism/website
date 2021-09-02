require "test_helper"

class Tracks::CommunitySolutionsControllerTest < ActionDispatch::IntegrationTest
  ########
  # Show #
  ########
  test "show: 404s silently for missing track" do
    get track_exercise_solution_url('foobar', 'foobar', 'foobar')

    assert_rendered_404
  end

  test "show: 404s silently for missing exercise" do
    get track_exercise_solution_url(create(:track), 'foobar', 'foobar')

    assert_rendered_404
  end

  test "show: 404s silently for missing user" do
    exercise = create :practice_exercise
    get track_exercise_solution_url(exercise.track, exercise, 'foobar')

    assert_rendered_404
  end

  test "show: 404s silently for missing solution" do
    exercise = create :practice_exercise
    get track_exercise_solution_url(exercise.track, exercise, create(:user))

    assert_rendered_404
  end

  test "show: 404s silently for unpublished solution" do
    exercise = create :practice_exercise
    solution = create :practice_solution, exercise: exercise
    get track_exercise_solution_url(exercise.track, exercise, solution.user)

    assert_rendered_404
  end

  test "show: 200s for published solution" do
    exercise = create :practice_exercise
    solution = create :practice_solution, :published, exercise: exercise
    get track_exercise_solution_url(exercise.track, exercise, solution.user)

    assert_response 200
  end

  test "show: 200s for published solution with uuid" do
    exercise = create :practice_exercise
    solution = create :practice_solution, :published, exercise: exercise
    get track_exercise_solution_url(exercise.track, exercise, solution.uuid)

    assert_response 200
  end
end
