require 'test_helper'

module Git
  class TrackTest < ActiveSupport::TestCase
    test "passing_repo_works" do
      repo = Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
      track = Git::Track.new(repo:)
      assert_equal("ruby", track.slug)
    end

    test "passing_repo_url_works" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal("ruby", track.slug)
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

    test "retrieves_about" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      expected = "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity.\nIt has an elegant syntax that is natural to read and easy to write." # rubocop:disable Layout/LineLength
      assert_equal(expected, track.about)
    end

    test "retrieves_snippet" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      expected = "class HelloWorld\n  def self.hello(name = 'World')\n    \"Hello, \#{name}!\"\n  end\nend"
      assert_equal(expected, track.snippet)
    end

    test "retrieves_key_features" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      expected = ["Developer happiness", "Metaprogramming magic", "Garbage Collection", "Large standard library",
                  "Flexible package manager", "Strong, dynamic typing"]
      assert_equal(expected, track.key_features.map { |f| f[:title] })
    end

    test "retrieves_debugging_instructions" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      expected = "# Debug\n\nYou can debug by printing to the console."
      assert_equal expected, track.debugging_instructions
    end

    test "retrieves_help" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      expected = "# Help\n\nStuck? Try the Ruby gitter channel."
      assert_equal expected, track.help
    end

    test "retrieves_tests" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      expected = "# Tests\n\nRun the tests using `ruby test`."
      assert_equal expected, track.tests
    end

    test "about file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('docs/ABOUT.md', track.about_filepath)
    end

    test "about absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('docs/ABOUT.md', track.about_absolute_filepath)
    end

    test "snippet file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('docs/SNIPPET.txt', track.snippet_filepath)
    end

    test "snippet absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('docs/SNIPPET.txt', track.snippet_absolute_filepath)
    end

    test "debugging_instructions file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/shared/.docs/debug.md', track.debugging_instructions_filepath)
    end

    test "debugging_instructions absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/shared/.docs/debug.md', track.debugging_instructions_absolute_filepath)
    end

    test "help file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/shared/.docs/help.md', track.help_filepath)
    end

    test "help absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/shared/.docs/help.md', track.help_absolute_filepath)
    end

    test "tests file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/shared/.docs/tests.md', track.tests_filepath)
    end

    test "tests absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/shared/.docs/tests.md', track.tests_absolute_filepath)
    end

    test "representations file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/shared/.docs/representations.md', track.representations_filepath)
    end

    test "representations absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/shared/.docs/representations.md', track.representations_absolute_filepath)
    end

    test "config file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('config.json', track.config_filepath)
    end

    test "config absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('config.json', track.config_absolute_filepath)
    end

    test "representer_normalizations file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('docs/REPRESENTER_NORMALIZATIONS.md', track.representer_normalizations_filepath)
    end

    test "representer_normalizations absolute file path" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('docs/REPRESENTER_NORMALIZATIONS.md', track.representer_normalizations_absolute_filepath)
    end

    test "has_concept_exercises?" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert track.has_concept_exercises?
    end

    test "has_test_runner?" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert track.has_test_runner?
    end

    test "has_representer?" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert track.has_representer?
    end

    test "has_analyzer?" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      refute track.has_analyzer?
    end

    test "indent_style" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal :space, track.indent_style
    end

    test "indent_size" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal 2, track.indent_size
    end

    test "ace_editor_language" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal "ruby", track.ace_editor_language
    end

    test "highlightjs_language" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal "ruby", track.highlightjs_language
    end

    test "average_test_duration" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal 1.2, track.average_test_duration
    end

    test "title" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal "Ruby", track.title
    end

    test "slug" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal "ruby", track.slug
    end

    test "blurb" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      expected = "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity."
      assert_equal expected, track.blurb
    end

    test "active?" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      assert track.active?
    end

    test "tags" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      expected = [
        "execution_mode/interpreted",
        "platform/windows",
        "platform/linux",
        "platform/mac",
        "paradigm/declarative",
        "paradigm/object_oriented"
      ]
      assert_equal expected, track.tags
    end

    test "foregone_exercises" do
      track = Git::Track.new(repo_url: TestHelpers.git_repo_url("track"))
      expected = %w[alphametics zipper]
      assert_equal expected, track.foregone_exercises
    end
  end
end
