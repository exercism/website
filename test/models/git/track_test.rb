require 'test_helper'

module Git
  class TrackTest < Minitest::Test
    def test_passing_repo_works
      repo = Repository.new(:csharp, repo_url: TestHelpers.git_repo_url("v3-monorepo"))
      track = Track.new(:csharp, repo: repo)
      assert_equal(/.+test[.]rb$/, track.test_regexp)
    end

    def test_passing_repo_url_works
      track = Track.new(:csharp, repo_url: TestHelpers.git_repo_url("v3-monorepo"))
      assert_equal(/.+test[.]rb$/, track.test_regexp)
    end

    def test_passing_both_repo_and_repo_url_raises
      assert_raises do
        Repository.new(track_slug, repo_url: "foobar", repo: "barfoo")
      end
    end

    def test_passing_neither_repo_and_repo_url_raises
      assert_raises do
        Repository.new(track_slug)
      end
    end

    def test_monorepo_test_regexp
      track = Track.new(:csharp, repo_url: TestHelpers.git_repo_url("v3-monorepo"))
      assert_equal(/.+test[.]rb$/, track.test_regexp)
    end

    def test_monorepo_ignore_regexp
      track = Track.new(:csharp, repo_url: TestHelpers.git_repo_url("v3-monorepo"))
      assert_equal(/[iI]gnore/, track.ignore_regexp)
    end

    def test_retrieves_test_regexp
      skip # TODO: Renable when not in monorepo
      track = Git::Track.new("track-with-exercises", :ruby)
      assert_equal(/test/, track.test_regexp)
    end

    def test_has_correct_default_test_regexp
      skip # TODO: Renable when not in monorepo
      track = Git::Track.new(TestHelpers.git_repo_url("track-naked"), :ruby)
      assert_equal(/[tT]est/, track.test_regexp)
    end

    def test_retrieves_ignore_regexp
      skip # TODO: Renable when not in monorepo
      track = Git::Track.new(TestHelpers.git_repo_url("track-with-exercises"), :ruby)
      assert_equal(/[iI]gno/, track.ignore_regexp)
    end

    def test_has_correct_default_ignore_regexp
      skip # TODO: Renable when not in monorepo
      track = Git::Track.new(TestHelpers.git_repo_url("track-naked"), :ruby)
      assert_equal(/[iI]gnore/, track.ignore_regexp)
    end
  end
end
