require "test_helper"

class Track::UnimplementedPracticeExercisesTest < ActiveSupport::TestCase
  test "does not include foregone exercises" do
    track = create :track

    unimplemented_exercises = Track::UnimplementedPracticeExercises.(track)

    refute_includes unimplemented_exercises, "alphametics"
    refute_includes unimplemented_exercises, "zipper"
  end

  test "does not include implemented exercises" do
    track = create :track
    create :practice_exercise, slug: 'leap'
    create :practice_exercise, slug: 'hamming'

    unimplemented_exercises = Track::UnimplementedPracticeExercises.(track)

    refute_includes unimplemented_exercises, "leap"
    refute_includes unimplemented_exercises, "hamming"
  end

  test "includes unimplemented" do
    track = create :track
    create :practice_exercise, slug: 'leap'
    create :practice_exercise, slug: 'hamming'

    unimplemented_exercises = Track::UnimplementedPracticeExercises.(track)

    assert_includes unimplemented_exercises, "bob"
    assert_includes unimplemented_exercises, "forth"
  end
end
