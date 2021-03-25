require 'test_helper'

class SerializeExercisesTest < ActiveSupport::TestCase
  test "without user track" do
    concept_exercise = create :concept_exercise
    practice_exercise = create :practice_exercise

    expected = [{
      slug: concept_exercise.slug,
      title: concept_exercise.title,
      icon_url: concept_exercise.icon_url,
      blurb: concept_exercise.blurb,
      available: nil
    }, {
      slug: practice_exercise.slug,
      title: practice_exercise.title,
      icon_url: practice_exercise.icon_url,
      blurb: practice_exercise.blurb,
      available: nil
    }]

    assert_equal expected, SerializeExercises.(
      [concept_exercise, practice_exercise]
    )
  end

  test "with user track" do
    user = create :user
    track = create :track
    user_track = create :user_track, user: user, track: track
    concept_exercise = create :concept_exercise, track: track
    practice_exercise = create :practice_exercise, track: track
    create :exercise_prerequisite, exercise: practice_exercise

    expected = [{
      slug: concept_exercise.slug,
      title: concept_exercise.title,
      icon_url: concept_exercise.icon_url,
      blurb: concept_exercise.blurb,
      available: true
    }, {
      slug: practice_exercise.slug,
      title: practice_exercise.title,
      icon_url: practice_exercise.icon_url,
      blurb: practice_exercise.blurb,
      available: false
    }]

    assert_equal expected, SerializeExercises.(
      [concept_exercise, practice_exercise],
      user_track: user_track
    )
  end
end
