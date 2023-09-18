require 'test_helper'

class Track::UpdateNumExercisesTest < ActiveSupport::TestCase
  test "recache_num_exercises!" do
    track = create :track
    Track::UpdateNumExercises.(track)
    assert_equal 0, track.num_exercises

    create :practice_exercise, track:, status: :beta
    Track::UpdateNumExercises.(track)
    assert_equal 1, track.num_exercises

    create :practice_exercise, track:, status: :active
    Track::UpdateNumExercises.(track)
    assert_equal 2, track.reload.num_exercises

    # Ignore wip practice exercises
    create :practice_exercise, track:, status: :wip
    Track::UpdateNumExercises.(track)
    assert_equal 2, track.reload.num_exercises

    # Ignore deprecated practice exercises
    create :practice_exercise, track:, status: :deprecated
    Track::UpdateNumExercises.(track)
    assert_equal 2, track.reload.num_exercises

    # Ignore concept exercises when the track does not have a course
    track.update(course: false)
    create :concept_exercise, track:, status: :active
    Track::UpdateNumExercises.(track)
    assert_equal 2, track.reload.num_exercises

    # Include concept exercises when the track has a course
    track.update(course: true)
    create :concept_exercise, track:, status: :beta
    Track::UpdateNumExercises.(track)
    assert_equal 4, track.reload.num_exercises

    # Ignore wip concept exercises
    create :concept_exercise, track:, status: :wip
    Track::UpdateNumExercises.(track)
    assert_equal 4, track.reload.num_exercises

    # Ignore deprecated concept exercises
    create :concept_exercise, track:, status: :deprecated
    Track::UpdateNumExercises.(track)
    assert_equal 4, track.reload.num_exercises
  end
end
