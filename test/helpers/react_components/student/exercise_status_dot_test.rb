require_relative "../react_component_test_case"

class ReactComponents::Student::ExerciseStatusDotTest < ReactComponentTestCase
  test "is correct with user_track" do
    track = create :track
    exercise = create(:practice_exercise, track:)
    user_track = create(:user_track, track:)

    component = render(ReactComponents::Student::ExerciseStatusDot.new(exercise, user_track))
    assert_component component,
      "student-exercise-status-dot",
      {
        slug: exercise.slug,
        exercise_status: :locked,
        type: :practice,
        links: {
          exercise: Exercism::Routes.track_exercise_url(track, exercise),
          tooltip: Exercism::Routes.tooltip_track_exercise_url(track, exercise)
        }
      }
  end

  test "is correct with external user_track" do
    track = create :track
    exercise = create(:practice_exercise, track:)

    component = ReactComponents::Student::ExerciseStatusDot.new(exercise, UserTrack::External.new(track))
    assert_component component,
      "student-exercise-status-dot",
      {
        slug: exercise.slug,
        exercise_status: :external,
        type: :practice,
        links: {
          exercise: Exercism::Routes.track_exercise_url(track, exercise),
          tooltip: Exercism::Routes.tooltip_track_exercise_url(track, exercise)
        }
      }
  end

  test "is correct with nil user_track" do
    exercise = create :practice_exercise

    component = ReactComponents::Student::ExerciseStatusDot.new(exercise, nil)
    assert_component component,
      "student-exercise-status-dot",
      {
        slug: exercise.slug,
        exercise_status: :external,
        type: :practice,
        links: {
          exercise: Exercism::Routes.track_exercise_url(exercise.track, exercise),
          tooltip: Exercism::Routes.tooltip_track_exercise_url(exercise.track, exercise)
        }
      }
  end
end
