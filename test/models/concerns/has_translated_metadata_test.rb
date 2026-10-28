require "test_helper"

class HasTranslatedMetadataTest < ActiveSupport::TestCase
  REPO_NAME = "track".freeze

  test "a wip or deprecated exercise with no translation falls back to english and is not reported" do
    wip = create :practice_exercise, slug: "bob", title: "Bob", status: :wip
    deprecated = create :practice_exercise, slug: "leap", title: "Leap", status: :deprecated, track: wip.track

    with_published_translations({}) do
      publish_translated_metadata!(:hu, REPO_NAME, {})
      TranslationRepo.expects(:report_missing_metadata!).never

      I18n.with_locale(:hu) do
        assert_equal "Bob", wip.title
        assert_equal "Leap", deprecated.title
      end
    end
  end

  test "a deprecated exercise with a translation still uses it" do
    exercise = create :practice_exercise, slug: "bob", title: "Bob", status: :deprecated

    with_published_translations({}) do
      publish_translated_metadata!(:hu, REPO_NAME, { "exercise:bob:name" => "Bobó" })

      I18n.with_locale(:hu) { assert_equal "Bobó", exercise.title }
    end
  end

  test "an inactive track's metadata with no translation falls back to english and is not reported" do
    track = create :track, active: false
    exercise = create(:practice_exercise, slug: "bob", title: "Bob", track:)
    concept = create(:concept, slug: "strings", name: "Strings", track:)

    with_published_translations({}) do
      publish_translated_metadata!(:hu, REPO_NAME, {})
      TranslationRepo.expects(:report_missing_metadata!).never

      I18n.with_locale(:hu) do
        assert_equal "Bob", exercise.title
        assert_equal "Strings", concept.name
        assert_equal track.read_attribute(:blurb), track.blurb
      end
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
end
