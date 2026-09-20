require "test_helper"

class TranslationRepo::MetadataTest < ActiveSupport::TestCase
  test "the metadata catalog lives beside the locale's other files" do
    Exercism.config.stubs(efs_repositories_mount_point: "/mnt/efs/repos")

    assert_equal "/mnt/efs/repos/i18n/locales/hu/metadata/ruby.json", TranslationRepo.metadata_path(:hu, "ruby").to_s
    assert_raises(ArgumentError) { TranslationRepo.metadata_path(:hu, "../../etc/passwd") }
    assert_raises(ArgumentError) { TranslationRepo.metadata_path(:hu, "") }
  end

  test "metadata is empty for english and for a repo with no catalog" do
    with_published_translations({}) do
      publish_translated_metadata!(:hu, "ruby", { "track:blurb" => "Szia" })

      assert_empty TranslationRepo.metadata(:en, "ruby")
      assert_empty TranslationRepo.metadata(:hu, "python")
      assert_nil TranslationRepo.metadata_text(:en, "ruby", "track:blurb")
      assert_nil TranslationRepo.metadata_text(:hu, "python", "track:blurb")
    end
  end

  test "metadata_text returns the unit's translation, or nil when it is absent or blank" do
    with_published_translations({}) do
      publish_translated_metadata!(:hu, "ruby", {
        "track:blurb" => "Egy dinamikus nyelv",
        "exercise:hello-world:name" => "Helló, világ!",
        "exercise:two-fer:name" => ""
      })

      assert_equal "Egy dinamikus nyelv", TranslationRepo.metadata_text(:hu, "ruby", "track:blurb")
      assert_equal "Helló, világ!", TranslationRepo.metadata_text(:hu, "ruby", "exercise:hello-world:name")
      assert_nil TranslationRepo.metadata_text(:hu, "ruby", "exercise:two-fer:name")
      assert_nil TranslationRepo.metadata_text(:hu, "ruby", "exercise:bob:name")
    end
  end

  test "the metadata catalog is memoised per version" do
    with_published_translations({}) do
      publish_translated_metadata!(:hu, "ruby", { "track:blurb" => "Első" })
      assert_equal "Első", TranslationRepo.metadata_text(:hu, "ruby", "track:blurb")

      File.write(TranslationRepo.metadata_path(:hu, "ruby"), { "track:blurb" => "Második" }.to_json)
      assert_equal "Első", TranslationRepo.metadata_text(:hu, "ruby", "track:blurb")

      commit_translations!
      assert_equal "Második", TranslationRepo.metadata_text(:hu, "ruby", "track:blurb")
    end
  end

  test "an unparseable metadata catalog is reported and read as empty" do
    with_published_translations({}) do
      write_translation!(TranslationRepo.metadata_path(:hu, "ruby"), "{ nope")
      Sentry.expects(:capture_exception).once

      assert_empty TranslationRepo.metadata(:hu, "ruby")
    end
  end
end
