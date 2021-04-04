require 'test_helper'

class SerializeExerciseTest < ActiveSupport::TestCase
  test "concept exercise without user track" do
    exercise = create :concept_exercise

    expected = {
      slug: exercise.slug,
      title: exercise.title,
      icon_url: exercise.icon_url,
      blurb: exercise.blurb,
      difficulty: "easy",
      is_external: true,
      is_unlocked: true,
      is_recommended: false,
      is_completed: false,
      links: {
        self: Exercism::Routes.track_exercise_path(exercise.track, exercise)
      }
    }

    assert_equal expected, SerializeExercise.(exercise)
  end

  test "practice exercise without user track" do
    exercise = create :practice_exercise

    expected = {
      slug: exercise.slug,
      title: exercise.title,
      icon_url: exercise.icon_url,
      blurb: exercise.blurb,
      difficulty: "easy",
      is_external: true,
      is_unlocked: true,
      is_recommended: false,
      is_completed: false,
      links: {
        self: Exercism::Routes.track_exercise_path(exercise.track, exercise)
      }
    }

    assert_equal expected, SerializeExercise.(exercise)
  end

  test "with external user track" do
    exercise = create :concept_exercise

    expected = {
      slug: exercise.slug,
      title: exercise.title,
      icon_url: exercise.icon_url,
      blurb: exercise.blurb,
      difficulty: "easy",
      is_external: true,
      is_unlocked: true,
      is_recommended: false,
      is_completed: false,
      links: {
        self: Exercism::Routes.track_exercise_path(exercise.track, exercise)
      }
    }

    assert_equal expected, SerializeExercise.(
      exercise,
      user_track: UserTrack::External.new(exercise.track)
    )
  end

  test "concept with user track" do
    user = create :user
    track = create :track
    user_track = create :user_track, user: user, track: track
    exercise = create :concept_exercise, track: track

    create :hello_world_solution, :completed, track: track, user: user

    expected = {
      slug: exercise.slug,
      title: exercise.title,
      icon_url: exercise.icon_url,
      blurb: exercise.blurb,
      difficulty: "easy",
      is_external: false,
      is_unlocked: true,
      is_recommended: false,
      is_completed: false,
      links: {
        self: Exercism::Routes.track_exercise_path(track, exercise)
      }
    }

    assert_equal expected, SerializeExercise.(
      exercise,
      user_track: user_track
    )
  end

  test "practice with user track" do
    user = create :user
    track = create :track
    user_track = create :user_track, user: user, track: track
    exercise = create :practice_exercise, track: track
    create :exercise_prerequisite, exercise: exercise

    create :hello_world_solution, :completed, track: track, user: user

    expected = {

      slug: exercise.slug,
      title: exercise.title,
      icon_url: exercise.icon_url,
      blurb: exercise.blurb,
      difficulty: "easy",
      is_external: false,
      is_unlocked: false,
      is_recommended: false,
      is_completed: false,
      links: {}
    }

    assert_equal expected, SerializeExercise.(
      exercise,
      user_track: user_track
    )
  end
end
