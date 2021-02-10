require 'test_helper'

module Git
  class ExerciseTest < ActiveSupport::TestCase
    test "solution_files" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))

      expected_files = ["log_line_parser.rb"]
      assert_equal expected_files, exercise.solution_files.keys
      assert exercise.solution_files["log_line_parser.rb"].start_with?("module LogLineParser")
    end

    test "read_file_blob" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))

      assert_equal "stub content\n", exercise.read_file_blob('bob.rb')
    end

    test "tooling_files" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))

      assert_equal exercise.tooling_filepaths, exercise.tooling_files.keys
      assert exercise.tooling_files["bob.rb"].start_with?("stub content")
    end

    test "tooling_filepaths" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))

      expected_filepaths = [
        ".docs/hints.md",
        ".docs/instructions.md",
        ".meta/config.json",
        ".meta/example.rb",
        "bob.rb",
        "bob_test.rb",
        "subdir/more_bob.rb"
      ]
      assert_equal expected_filepaths, exercise.tooling_filepaths
    end

    test "cli_filepaths with hints" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))

      expected_filepaths = [
        "README.md",
        "HELP.md",
        "HINTS.md",
        "bob.rb",
        "bob_test.rb",
        "subdir/more_bob.rb"
      ]
      assert_equal expected_filepaths, exercise.cli_filepaths
    end

    test "cli_filepaths without hints" do
      exercise = Git::Exercise.new(:anagram, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))

      expected_filepaths = [
        "README.md",
        "HELP.md",
        "anagram.rb",
        "anagram_test.rb"
      ]
      assert_equal expected_filepaths, exercise.cli_filepaths
    end
  end
end
