require "test_helper"

class GenericExercise::CreateOrUpdateTest < ActiveSupport::TestCase
  test "creates new exercise" do
    slug = 'anagram'
    title = 'Anagram'
    blurb = 'Given a word and a list of possible anagrams, select the correct sublist.'
    source = 'Inspired by the Extreme Startup game'
    source_url = 'https://github.com/rchatley/extreme_startup'
    deep_dive_youtube_id = 'yYnqweoy12'
    deep_dive_blurb = 'Explore 14 different ways to solve Anagram.'
    status = :active

    exercise = GenericExercise::CreateOrUpdate.(slug, title, blurb, source, source_url, deep_dive_youtube_id, deep_dive_blurb, status)

    assert_equal 1, GenericExercise.count
    assert_equal GenericExercise.last, exercise

    assert_equal slug, exercise.slug
    assert_equal title, exercise.title
    assert_equal blurb, exercise.blurb
    assert_equal source, exercise.source
    assert_equal source_url, exercise.source_url
    assert_equal deep_dive_youtube_id, exercise.deep_dive_youtube_id
    assert_equal deep_dive_blurb, exercise.deep_dive_blurb
    assert_equal status, exercise.status
  end

  test "updates existing exercise" do
    slug = 'anagram'
    title = 'Anagram'
    blurb = 'Given a word and a list of possible anagrams, select the correct sublist.'
    source = 'Inspired by the Extreme Startup game'
    source_url = 'https://github.com/rchatley/extreme_startup'
    deep_dive_youtube_id = 'yYnqweoy12'
    deep_dive_blurb = 'Explore 14 different ways to solve Anagram.'
    status = :active

    exercise = create(:generic_exercise, slug:, title:, blurb:, source:, source_url:, deep_dive_youtube_id:, deep_dive_blurb:, status:)

    new_title = 'The Gram'
    new_blurb = 'Make a selection.'
    new_status = :deprecated

    GenericExercise::CreateOrUpdate.(slug, new_title, new_blurb, source, source_url, deep_dive_youtube_id, deep_dive_blurb, new_status)

    assert_equal 1, GenericExercise.count
    assert_equal GenericExercise.last, exercise

    exercise.reload
    assert_equal slug, exercise.slug
    assert_equal new_title, exercise.title
    assert_equal new_blurb, exercise.blurb
    assert_equal source, exercise.source
    assert_equal source_url, exercise.source_url
    assert_equal deep_dive_youtube_id, exercise.deep_dive_youtube_id
    assert_equal deep_dive_blurb, exercise.deep_dive_blurb
    assert_equal new_status, exercise.status
  end

  test "idempotent" do
    slug = 'anagram'
    title = 'Anagram'
    blurb = 'Given a word and a list of possible anagrams, select the correct sublist.'
    source = 'Inspired by the Extreme Startup game'
    source_url = 'https://github.com/rchatley/extreme_startup'
    deep_dive_youtube_id = 'yYnqweoy12'
    deep_dive_blurb = 'Explore 14 different ways to solve Anagram.'
    status = :active

    assert_idempotent_command do
      GenericExercise::CreateOrUpdate.(slug, title, blurb, source, source_url, deep_dive_youtube_id, deep_dive_blurb, status)
    end

    assert_equal 1, GenericExercise.count
  end
end
