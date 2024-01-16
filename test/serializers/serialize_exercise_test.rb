require 'test_helper'

class SerializeExerciseTest < ActiveSupport::TestCase
  test "concept exercise without user track" do
    exercise = create :concept_exercise

    expected = {
      slug: exercise.slug,
      type: "concept",
      title: exercise.title,
      icon_url: exercise.icon_url,
      blurb: exercise.blurb,
      difficulty: :easy,
      is_external: true,
      is_unlocked: true,
      is_recommended: false,
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
      type: "practice",
      title: exercise.title,
      icon_url: exercise.icon_url,
      blurb: exercise.blurb,
      difficulty: :easy,
      is_external: true,
      is_unlocked: true,
      is_recommended: false,
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
      type: "concept",
      title: exercise.title,
      icon_url: exercise.icon_url,
      blurb: exercise.blurb,
      difficulty: :easy,
      is_external: true,
      is_unlocked: true,
      is_recommended: false,
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
    user_track = create(:user_track, user:, track:)
    exercise = create(:concept_exercise, track:)

    create(:hello_world_solution, :completed, track:, user:)

    expected = {
      slug: exercise.slug,
      type: "concept",
      title: exercise.title,
      icon_url: exercise.icon_url,
      blurb: exercise.blurb,
      difficulty: :easy,
      is_external: false,
      is_unlocked: true,
      is_recommended: false,
      links: {
        self: Exercism::Routes.track_exercise_path(track, exercise)
      }
    }

    assert_equal expected, SerializeExercise.(
      exercise,
      user_track:
    )
  end

  test "practice with user track" do
    user = create :user
    track = create :track
    concept = create :concept
    concept_exercise = create(:concept_exercise, track:)
    concept_exercise.taught_concepts << concept
    user_track = create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    exercise.prerequisites << concept

    create(:hello_world_solution, :completed, track:, user:)

    expected = {
      slug: exercise.slug,
      type: "practice",
      title: exercise.title,
      icon_url: exercise.icon_url,
      blurb: exercise.blurb,
      difficulty: :easy,
      is_external: false,
      is_unlocked: false,
      is_recommended: false,
      links: {
        self: Exercism::Routes.track_exercise_path(exercise.track, exercise)
      }
    }

    assert_equal expected, SerializeExercise.(
      exercise,
      user_track:
    )
  end

  test "hello world is tutorial" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create :practice_exercise, track:, slug: "hello-world"

    assert_equal "tutorial", SerializeExercise.(exercise)[:type]
  end
end
