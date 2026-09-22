require "test_helper"

class GenericExerciseTest < ActiveSupport::TestCase
  test "a problem specification's text comes from its catalog in a non-default locale" do
    generic_exercise = create :generic_exercise, slug: "anagram", deep_dive_blurb: "A deep dive"
    exercise = create :practice_exercise, slug: "anagram"

    with_published_translations({}) do
      publish_translated_metadata!(:hu, "problem-specifications", {
        "exercise:anagram:title" => "Anagramma",
        "exercise:anagram:blurb" => "Válaszd ki az anagrammákat.",
        "exercise:anagram:source" => "Az Extreme Startup játék ihlette",
        "exercise:anagram:deep_dive_blurb" => "Egy mélyfúrás"
      })

      assert_equal "Anagram", generic_exercise.title

      I18n.with_locale(:hu) do
        assert_equal "Anagramma", generic_exercise.title
        assert_equal "Válaszd ki az anagrammákat.", generic_exercise.blurb
        assert_equal "Az Extreme Startup játék ihlette", generic_exercise.source
        assert_equal "Egy mélyfúrás", generic_exercise.deep_dive_blurb
        assert_equal "Egy mélyfúrás", exercise.deep_dive_blurb
      end
    end
  end
end
