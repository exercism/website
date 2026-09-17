require "test_helper"

class Solution::ResolveDocsTest < ActiveSupport::TestCase
  # bob, before its instructions were updated and the appends added
  OLD_SHA = "7a42b345ebfa4e74899174abb4ed6b9301cf93b9".freeze
  LATEST_DOCS = %w[instructions.md instructions.append.md introduction.md introduction.append.md hints.md].freeze

  setup do
    @exercise = create :practice_exercise, slug: "bob"
    @repo = Git::Repository.new(repo_url: @exercise.track.repo_url)
    @old_sha = OLD_SHA
    @solution = create :practice_solution, exercise: @exercise, git_sha: @old_sha
  end

  def publish!(git_sha, path, text)
    commit = @repo.lookup_commit(git_sha)
    publish_translated_content!(:hu, @repo, commit, "exercises/practice/bob/#{path}", text)
  end

  test "english always shows the pinned version" do
    docs = Solution::ResolveDocs.(@solution)

    assert_equal @old_sha, docs.git_exercise.send(:git_sha)
    refute docs.for_newer_version?
    refute @solution.docs_for_newer_version?
  end

  test "a translated pinned version is shown as is" do
    with_published_translations({}) do
      %w[instructions.md hints.md].each { |file| publish!(@old_sha, ".docs/#{file}", "régi #{file}") }

      I18n.with_locale(:hu) do
        refute @solution.docs_for_newer_version?
        assert_includes @solution.instructions, "régi instructions.md"
      end
    end
  end

  test "with nothing translated, the pinned english is the fallback" do
    with_published_translations({}) do
      I18n.with_locale(:hu) do
        refute @solution.docs_for_newer_version?
        assert_equal @old_sha, @solution.docs.git_exercise.send(:git_sha)
      end
    end
  end

  test "an untranslated pinned version shows the latest version's translation, flagged" do
    with_published_translations({}) do
      LATEST_DOCS.each { |file| publish!(@exercise.git_sha, ".docs/#{file}", "új #{file}") }

      I18n.with_locale(:hu) do
        assert @solution.docs_for_newer_version?
        assert_equal "új instructions.md\n\núj instructions.append.md", @solution.instructions
        assert_equal "új hints.md", @solution.hints
      end

      # English still shows the student their own version
      refute @solution.docs_for_newer_version?
      refute_includes @solution.instructions, "új"
    end
  end

  test "byte-identical files resolve for an old version without being translated twice" do
    with_published_translations({}) do
      publish!(@exercise.git_sha, ".docs/hints.md", "új hints.md")

      I18n.with_locale(:hu) { assert_equal "új hints.md", Git::Exercise.for_solution(@solution).hints }
    end
  end

  test "a partly translated latest version is not good enough" do
    with_published_translations({}) do
      publish!(@exercise.git_sha, ".docs/instructions.md", "új")

      I18n.with_locale(:hu) { refute @solution.docs_for_newer_version? }
    end
  end

  test "an up to date solution is never flagged" do
    @solution.update!(git_sha: @exercise.git_sha)

    with_published_translations({}) do
      I18n.with_locale(:hu) { refute @solution.docs_for_newer_version? }
    end
  end

  test "the exercise page's cached content is per locale and carries the flag" do
    with_published_translations({}) do
      LATEST_DOCS.each { |file| publish!(@exercise.git_sha, ".docs/#{file}", "új #{file}") }

      english = Exercise::CachedContent::Generate.(@exercise, @solution)
      refute english[:for_newer_version]

      I18n.with_locale(:hu) do
        content = Exercise::CachedContent::Generate.(@exercise, @solution)
        assert content[:for_newer_version]
        assert_includes content[:instructions], "új instructions.md"
      end
    end
  end
end
