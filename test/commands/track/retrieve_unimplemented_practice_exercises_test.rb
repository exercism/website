require "test_helper"

class Track::RetrieveUnimplementedPracticeExercisesTest < ActiveSupport::TestCase
  test "does not include foregone exercises" do
    track = create :track
    create(:generic_exercise, slug: 'alphametics')
    create(:generic_exercise, slug: 'anagram')
    create(:generic_exercise, slug: 'leap')
    create(:generic_exercise, slug: 'zipper')

    unimplemented_exercise_slugs = Track::RetrieveUnimplementedPracticeExercises.(track).map(&:slug)

    assert_equal %w[anagram leap], unimplemented_exercise_slugs.sort
  end

  test "does not include implemented exercises" do
    track = create :track
    create :practice_exercise, slug: 'leap'
    create :practice_exercise, slug: 'hamming'

    create :generic_exercise, slug: 'forth'
    create :generic_exercise, slug: 'bob'
    create :generic_exercise, slug: 'leap'
    create :generic_exercise, slug: 'hamming'

    unimplemented_exercise_slugs = Track::RetrieveUnimplementedPracticeExercises.(track).map(&:slug)

    assert_equal %w[bob forth], unimplemented_exercise_slugs.sort
  end

  test "includes unimplemented" do
    track = create :track
    create :practice_exercise, slug: 'leap'
    create :practice_exercise, slug: 'hamming'

    create :generic_exercise, slug: 'forth'
    create :generic_exercise, slug: 'bob'
    create :generic_exercise, slug: 'leap'
    create :generic_exercise, slug: 'hamming'

    unimplemented_exercise_slugs = Track::RetrieveUnimplementedPracticeExercises.(track).map(&:slug)

    assert_equal %w[bob forth], unimplemented_exercise_slugs.sort
  end
end
