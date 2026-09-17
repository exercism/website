require 'test_helper'

class Git::TranslatedContentTest < ActiveSupport::TestCase
  setup do
    @exercise = Git::Exercise.new(:bob, "practice", "HEAD", repo_url: TestHelpers.git_repo_url("track"))
  end

  def publish!(path, text)
    publish_translated_content!(:hu, @exercise.send(:repo), @exercise.send(:commit), "exercises/practice/bob/#{path}", text)
  end

  test "english never touches the store" do
    TranslationStore.expects(:content).never

    assert_includes @exercise.instructions, "Instructions for bob"
    assert @exercise.instructions_translated?
  end

  test "reads the translation filed under the english blob id" do
    with_published_translations({}) do
      publish!(".docs/hints.md", "# Tippek\n")

      I18n.with_locale(:hu) { assert_equal "# Tippek", @exercise.hints }
      refute_includes @exercise.hints, "Tippek"
    end
  end

  test "instructions and their append are separate blobs, joined as the english is" do
    with_published_translations({}) do
      publish!(".docs/instructions.md", "# Utasítások\n\nBob utasításai\n")
      publish!(".docs/instructions.append.md", "# Kiegészítés\n\nTovábbi utasítások\n")

      I18n.with_locale(:hu) do
        assert_equal "# Utasítások\n\nBob utasításai\n\n# Kiegészítés\n\nTovábbi utasítások", @exercise.instructions
        assert_equal "# Kiegészítés\n\nTovábbi utasítások", @exercise.instructions_append
        assert @exercise.instructions_translated?
        refute @exercise.introduction_translated?
      end
    end
  end

  test "a part with no translation falls back to english on its own" do
    with_published_translations({}) do
      publish!(".docs/instructions.md", "# Utasítások\n")

      I18n.with_locale(:hu) do
        assert_equal "# Utasítások\n\n# Instructions append\n\nExtra instructions for bob", @exercise.instructions
        refute @exercise.instructions_translated?
      end
    end
  end

  test "the memoised text is per locale" do
    with_published_translations({}) do
      publish!(".docs/hints.md", "# Tippek")

      english = @exercise.hints
      I18n.with_locale(:hu) { assert_equal "# Tippek", @exercise.hints }
      assert_equal english, @exercise.hints
    end
  end

  test "english fallback is reported for a production locale only" do
    with_published_translations({}) do
      Sentry.expects(:capture_message).never
      I18n.with_locale(:hu) { assert_includes @exercise.hints, "Hints" }
    end

    LocaleRoster.stubs(production: %i[en hu])
    with_published_translations({}) do
      Sentry.expects(:capture_message).once.with { |message, **| message.include?("exercises/practice/bob/.docs/hints.md") }
      I18n.with_locale(:hu) { assert_includes Git::Exercise.new(:bob, "practice", "HEAD", repo_url: TestHelpers.git_repo_url("track")).hints, "Hints" }
    end
  end

  test "a file that doesn't exist is blank and needs no translation" do
    exercise = Git::Exercise.new(:strings, "concept", "HEAD", repo_url: TestHelpers.git_repo_url("track"))

    with_published_translations({}) do
      Sentry.expects(:capture_message).never
      I18n.with_locale(:hu) do
        assert_equal "", exercise.instructions_append
        assert exercise.instructions_append_translated?
      end
    end
  end

  test "concept and track documents are translatable too" do
    concept = Git::Concept.new(:strings, "HEAD", repo_url: TestHelpers.git_repo_url("track"))
    track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))

    with_published_translations({}) do
      publish_translated_content!(:hu, concept.send(:repo), concept.send(:commit), "concepts/strings/about.md", "A sztringekről")
      publish_translated_content!(:hu, track.send(:repo), track.send(:commit), "exercises/shared/.docs/help.md", "Segítség")

      I18n.with_locale(:hu) do
        assert_equal "A sztringekről", concept.about
        assert_equal "Segítség", track.help
      end
    end
  end
end
