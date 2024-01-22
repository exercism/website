require "test_helper"

class Track::RetrieveForegonePracticeExercisesTest < ActiveSupport::TestCase
  test "returns foregone exercises" do
    track = create :track
    create(:generic_exercise, slug: 'alphametics')
    create(:generic_exercise, slug: 'anagram')
    create(:generic_exercise, slug: 'leap')
    create(:generic_exercise, slug: 'zipper')

    foregone_exercise_slugs = Track::RetrieveForegonePracticeExercises.(track).map(&:slug)

    assert_equal %w[alphametics zipper], foregone_exercise_slugs.sort
  end
end
