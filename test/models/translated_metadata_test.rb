require "test_helper"

class TranslatedMetadataTest < ActiveSupport::TestCase
  REPO_NAME = "track".freeze

  test "an exercise's title, blurb and source come from the catalog in a non-default locale" do
    exercise = create :practice_exercise, slug: "bob", title: "Bob", blurb: "Bob is a lackadaisical teenager."

    with_published_translations({}) do
      publish_translated_metadata!(:hu, REPO_NAME, {
        "exercise:bob:name" => "Bob",
        "exercise:bob:blurb" => "Bob egy lusta tinédzser.",
        "exercise:bob:source" => "Egy forrás"
      })

      assert_equal "Bob is a lackadaisical teenager.", exercise.blurb

      I18n.with_locale(:hu) do
        assert_equal "Bob", exercise.title
        assert_equal "Bob egy lusta tinédzser.", exercise.blurb
        assert_equal "Egy forrás", exercise.source
      end
    end
  end

  test "a missing exercise unit renders nothing and is reported" do
    exercise = create :practice_exercise, slug: "bob", title: "Bob", blurb: "Bob is a lackadaisical teenager."

    with_published_translations({}) do
      publish_translated_metadata!(:hu, REPO_NAME, { "exercise:bob:name" => "Bob" })
      TranslationRepo.expects(:report_missing_metadata!).with(:hu, REPO_NAME, "exercise:bob:blurb")

      I18n.with_locale(:hu) { assert_equal "", exercise.blurb }
    end
  end

  test "an exercise with no english blurb reports nothing" do
    exercise = create :practice_exercise, slug: "bob", blurb: ""

    with_published_translations({}) do
      publish_translated_metadata!(:hu, REPO_NAME, {})
      TranslationRepo.expects(:report_missing_metadata!).never

      I18n.with_locale(:hu) { assert_equal "", exercise.blurb }
    end
  end

  test "a concept's name and blurb come from the catalog in a non-default locale" do
    concept = create :concept, slug: "strings", name: "Strings", blurb: "Strings are sequences of characters."

    with_published_translations({}) do
      publish_translated_metadata!(:hu, REPO_NAME, {
        "concept:strings:name" => "Karakterláncok",
        "concept:strings:blurb" => "A karakterláncok karakterek sorozatai."
      })

      assert_equal "Strings", concept.name

      I18n.with_locale(:hu) do
        assert_equal "Karakterláncok", concept.name
        assert_equal "A karakterláncok karakterek sorozatai.", concept.blurb
      end
    end
  end

  test "a track's blurb and key features come from the catalog in a non-default locale" do
    track = create :track

    with_published_translations({}) do
      publish_translated_metadata!(:hu, REPO_NAME, {
        "track:blurb" => "Egy dinamikus nyelv.",
        "key_feature:fun:title" => "Fejlesztői boldogság",
        "key_feature:fun:content" => "A Ruby a boldogságot tartja szem előtt."
      })

      assert_equal "Developer happiness", track.key_features.first[:title]

      I18n.with_locale(:hu) do
        assert_equal "Egy dinamikus nyelv.", track.blurb

        feature = track.key_features.first
        assert_equal "fun", feature[:icon]
        assert_equal "Fejlesztői boldogság", feature[:title]
        assert_equal "A Ruby a boldogságot tartja szem előtt.", feature[:content]
      end
    end
  end

  test "english never reaches the catalog" do
    exercise = create :practice_exercise, slug: "bob", title: "Bob"
    TranslationRepo.expects(:metadata_text).never

    assert_equal "Bob", exercise.title
    assert_equal "Developer happiness", exercise.track.key_features.first[:title]
  end

  test "the search indexes and the metrics broadcast stay english" do
    solution = create :practice_solution
    solution.exercise.update!(title: "Bob")

    with_published_translations({}) do
      publish_translated_metadata!(:hu, REPO_NAME, { "exercise:#{solution.exercise.slug}:name" => "Bob magyarul" })

      I18n.with_locale(:hu) do
        assert_equal "Bob", Solution::CreateSearchIndexDocument.(solution)[:exercise][:title]
      end
    end
  end
end
