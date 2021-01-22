require 'test_helper'

module Git
  class TrackTest < ActiveSupport::TestCase
    test "passing_repo_works" do
      repo = Git::Repository.new(:ruby, repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      track = Git::Track.new(:ruby, repo: repo)
      assert_equal(/test/, track.test_regexp)
    end

    test "passing_repo_url_works" do
      track = Git::Track.new(:ruby, repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal(/test/, track.test_regexp)
    end

    test "passing_both_repo_and_repo_url_raises" do
      assert_raises do
        Git::Repository.new(track_slug, repo_url: "foobar", repo: "barfoo")
      end
    end

    test "passing_neither_repo_and_repo_url_raises" do
      assert_raises do
        Git::Repository.new(track_slug)
      end
    end

    test "retrieves_test_regexp" do
      track = Git::Track.new(:ruby, repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal(/test/, track.test_regexp)
    end

    test "has_correct_default_test_regexp" do
      track = Git::Track.new(:track_naked, repo_url: TestHelpers.git_repo_url("track-naked"))
      assert_equal(/[tT]est/, track.test_regexp)
    end

    test "retrieves_ignore_regexp" do
      track = Git::Track.new(:ruby, repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal(/[iI]gno/, track.ignore_regexp)
    end

    test "has_correct_default_ignore_regexp" do
      track = Git::Track.new(:track_naked, repo_url: TestHelpers.git_repo_url("track-naked"))
      assert_equal(/[iI]gnore/, track.ignore_regexp)
    end

    test "retrieves_about" do
      track = Git::Track.new(:ruby, repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity.\nIt has an elegant syntax that is natural to read and easy to write.\n" # rubocop:disable Layout/LineLength
      assert_equal(expected, track.about)
    end

    test "retrieves_snippet" do
      track = Git::Track.new(:ruby, repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "class HelloWorld\n  def self.hello(name = 'World')\n    \"Hello, \#{name}!\"\n  end\nend\n"
      assert_equal(expected, track.snippet)
    end

    test "retrieves_key_features" do
      track = Git::Track.new(:ruby, repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = ["Modern", "Fun", "Full-featured", "Easy to learn", "Dynamic", "Expressive"]
      assert_equal(expected, track.key_features.map { |f| f[:title] })
    end
  end
end
