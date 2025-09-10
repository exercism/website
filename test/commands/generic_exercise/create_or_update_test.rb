require "test_helper"

class GenericExercise::CreateOrUpdateTest < ActiveSupport::TestCase
  test "creates new exercise" do
    attributes = {
      slug: 'anagram',
      title: 'Anagram',
      blurb: 'Given a word and a list of possible anagrams, select the correct sublist.',
      source: 'Inspired by the Extreme Startup game',
      source_url: 'https://github.com/rchatley/extreme_startup',
      deep_dive_youtube_id: 'yYnqweoy12',
      deep_dive_blurb: 'Explore 14 different ways to solve Anagram.',
      deprecated: false
    }

    repo_exercise = OpenStruct.new(attributes.merge(deprecated?: attributes[:deprecated]))
    exercise = GenericExercise::CreateOrUpdate.(repo_exercise)

    assert_equal 1, GenericExercise.count
    assert_equal GenericExercise.last, exercise

    attributes.except(:deprecated).each do |key, value|
      assert_equal value, exercise.public_send(key)
    end
    assert_equal :active, exercise.status
  end

  test "updates existing exercise" do
    attributes = {
      slug: 'anagram',
      title: 'Anagram',
      blurb: 'Given a word and a list of possible anagrams, select the correct sublist.',
      source: 'Inspired by the Extreme Startup game',
      source_url: 'https://github.com/rchatley/extreme_startup',
      deep_dive_youtube_id: 'yYnqweoy12',
      deep_dive_blurb: 'Explore 14 different ways to solve Anagram.',
      deprecated: false
    }

    exercise = create(:generic_exercise, **attributes.except(:deprecated))

    updated_attributes = attributes.merge(
      title: 'The Gram',
      blurb: 'Make a selection.',
      deprecated: true
    )

    repo_exercise = OpenStruct.new(updated_attributes.merge(deprecated?: updated_attributes[:deprecated]))
    GenericExercise::CreateOrUpdate.(repo_exercise)

    assert_equal 1, GenericExercise.count
    assert_equal GenericExercise.last, exercise

    exercise.reload
    assert_equal "The Gram", exercise.title
    assert_equal 'Make a selection.', exercise.blurb
    assert_equal :deprecated, exercise.status
  end

  test "idempotent" do
    attributes = {
      slug: 'anagram',
      title: 'Anagram',
      blurb: 'Given a word and a list of possible anagrams, select the correct sublist.',
      source: 'Inspired by the Extreme Startup game',
      source_url: 'https://github.com/rchatley/extreme_startup',
      deep_dive_youtube_id: 'yYnqweoy12',
      deep_dive_blurb: 'Explore 14 different ways to solve Anagram.',
      deprecated: false
    }

    repo_exercise = OpenStruct.new(attributes.merge(deprecated?: attributes[:deprecated]))
    assert_idempotent_command do
      GenericExercise::CreateOrUpdate.(repo_exercise)
    end

    assert_equal 1, GenericExercise.count
  end

  test "defers all the localizations correctly" do
    blurb = 'Given a word and a list of possible anagrams, select the correct sublist.'
    source = 'Inspired by the Extreme Startup game'
    title = "Anagram"

    instructions = "Some instructions"
    introduction = "Some introduction"

    attributes = {
      slug: 'anagram',
      title:,
      blurb:,
      source:,
      source_url: 'https://github.com/rchatley/extreme_startup',
      deep_dive_youtube_id: 'yYnqweoy12',
      deep_dive_blurb: 'Explore 14 different ways to solve Anagram.',
      deprecated: false
    }

    Localization::Text::AddToLocalization.expects(:defer).with(:generic_exercise_instructions, instructions, anything)
    Localization::Text::AddToLocalization.expects(:defer).with(:generic_exercise_introduction, introduction, anything)
    Localization::Text::AddToLocalization.expects(:defer).with(:generic_exercise_title, title, anything)
    Localization::Text::AddToLocalization.expects(:defer).with(:generic_exercise_blurb, blurb, anything)
    Localization::Text::AddToLocalization.expects(:defer).with(:generic_exercise_source, source, anything)

    repo_exercise = OpenStruct.new(attributes.merge(deprecated?: attributes[:deprecated], instructions:, introduction:))
    GenericExercise::CreateOrUpdate.(repo_exercise)
  end
end
