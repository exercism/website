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

  test "returns empty when git commit is missing" do
    track = create :track

    Git::Track.any_instance.stubs(:foregone_exercises).raises(Git::MissingCommitError)

    assert_empty Track::RetrieveForegonePracticeExercises.(track)
  end
end
