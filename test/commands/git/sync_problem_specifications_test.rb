require "test_helper"

class Git::SyncProblemSpecificationsTest < ActiveSupport::TestCase
  setup do
    TestHelpers.use_problem_specifications_test_repo!
  end

  test "creates new exercises" do
    Git::SyncProblemSpecifications.()

    assert_equal 137, GenericExercise.count
    assert_equal "accumulate", GenericExercise.first.slug
    assert_equal "zipper", GenericExercise.last.slug
  end

  test "updates existing exercises" do
    slug = 'anagram'
    title = 'The Gram'
    blurb = 'Make a selection.'
    source = 'Inspired by the Extreme Startup game'
    source_url = 'https://github.com/rchatley/extreme_startup'
    deep_dive_youtube_id = 'yYnqweoy12'
    status = :deprecated

    exercise = create(:generic_exercise, slug:, title:, blurb:, source:, source_url:, deep_dive_youtube_id:, status:)

    Git::SyncProblemSpecifications.()

    exercise.reload
    assert_equal 'Anagram', exercise.title
    assert_equal 'Given a word and a list of possible anagrams, select the correct sublist.', exercise.blurb
    assert_equal :active, exercise.status
  end

  test "syncs deep dive data" do
    Git::SyncProblemSpecifications.()

    exercise = GenericExercise.for!('raindrops')
    assert_equal "mwe-9RIV39Y", exercise.deep_dive_youtube_id
    assert_equal "Explore 14 different ways to solve Raindrops.", exercise.deep_dive_blurb
  end
end
