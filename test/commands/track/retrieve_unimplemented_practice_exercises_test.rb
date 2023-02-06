require "test_helper"

class Track::RetrieveUnimplementedPracticeExercisesTest < ActiveSupport::TestCase
  test "does not include foregone exercises" do
    track = create :track

    unimplemented_exercise_slugs = Track::RetrieveUnimplementedPracticeExercises.(track).map(&:slug)

    refute_includes unimplemented_exercise_slugs, "alphametics"
    refute_includes unimplemented_exercise_slugs, "zipper"
  end

  test "does not include implemented exercises" do
    track = create :track
    create :practice_exercise, slug: 'leap'
    create :practice_exercise, slug: 'hamming'

    unimplemented_exercise_slugs = Track::RetrieveUnimplementedPracticeExercises.(track).map(&:slug)

    refute_includes unimplemented_exercise_slugs, "leap"
    refute_includes unimplemented_exercise_slugs, "hamming"
  end

  test "includes unimplemented" do
    track = create :track
    create :practice_exercise, slug: 'leap'
    create :practice_exercise, slug: 'hamming'

    unimplemented_exercise_slugs = Track::RetrieveUnimplementedPracticeExercises.(track).map(&:slug)

    assert_includes unimplemented_exercise_slugs, "bob"
    assert_includes unimplemented_exercise_slugs, "forth"
  end
end
