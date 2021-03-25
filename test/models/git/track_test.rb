require 'test_helper'

module Git
  class TrackTest < ActiveSupport::TestCase
    test "passing_repo_works" do
      repo = Git::Repository.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      track = Git::Track.new(repo: repo)
      assert_equal(/test/, track.test_regexp)
    end

    test "passing_repo_url_works" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal(/test/, track.test_regexp)
    end

    test "passing_both_repo_and_repo_url_raises" do
      assert_raises do
        Git::Repository.new(repo_url: "foobar", repo: "barfoo")
      end
    end

    test "passing_neither_repo_and_repo_url_raises" do
      assert_raises do
        Git::Repository.new
      end
    end

    test "retrieves_test_regexp" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal(/test/, track.test_regexp)
    end

    test "has_correct_default_test_regexp" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-naked"))
      assert_equal(/[tT]est/, track.test_regexp)
    end

    test "retrieves_ignore_regexp" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal(/[iI]gno/, track.ignore_regexp)
    end

    test "has_correct_default_ignore_regexp" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-naked"))
      assert_equal(/[iI]gnore/, track.ignore_regexp)
    end

    test "retrieves_about" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity.\nIt has an elegant syntax that is natural to read and easy to write.\n" # rubocop:disable Layout/LineLength
      assert_equal(expected, track.about)
    end

    test "retrieves_snippet" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "class HelloWorld\n  def self.hello(name = 'World')\n    \"Hello, \#{name}!\"\n  end\nend\n"
      assert_equal(expected, track.snippet)
    end

    test "retrieves_key_features" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = ["Modern", "Fun", "Full-featured", "Easy to learn", "Dynamic", "Expressive"]
      assert_equal(expected, track.key_features.map { |f| f[:title] })
    end

    test "retrieves_debugging_instructions" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "# Debug\n\nYou can debug by printing to the console.\n"
      assert_equal expected, track.debugging_instructions
    end

    test "retrieves_help" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "# Help\n\nStuck? Try the Ruby gitter channel.\n"
      assert_equal expected, track.help
    end

    test "retrieves_tests" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "# Tests\n\nRun the tests using `ruby test`.\n"
      assert_equal expected, track.tests
    end

    test "about file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('docs/ABOUT.md', track.about_filepath)
    end

    test "about absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('docs/ABOUT.md', track.about_absolute_filepath)
    end

    test "snippet file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('docs/SNIPPET.txt', track.snippet_filepath)
    end

    test "snippet absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('docs/SNIPPET.txt', track.snippet_absolute_filepath)
    end

    test "debugging_instructions file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('exercises/shared/.docs/debug.md', track.debugging_instructions_filepath)
    end

    test "debugging_instructions absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('exercises/shared/.docs/debug.md', track.debugging_instructions_absolute_filepath)
    end

    test "help file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('exercises/shared/.docs/help.md', track.help_filepath)
    end

    test "help absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('exercises/shared/.docs/help.md', track.help_absolute_filepath)
    end

    test "tests file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('exercises/shared/.docs/tests.md', track.tests_filepath)
    end

    test "tests absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('exercises/shared/.docs/tests.md', track.tests_absolute_filepath)
    end

    test "config file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('config.json', track.config_filepath)
    end

    test "config absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      assert_equal('config.json', track.config_absolute_filepath)
    end
  end
end
