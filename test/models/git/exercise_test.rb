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
        ".docs/instructions.append.md",
        ".docs/instructions.md",
        ".docs/introduction.append.md",
        ".docs/introduction.md",
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

    test "retrieves_instructions" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "# Instructions\n\nInstructions for bob\n"
      assert_equal(expected, exercise.instructions)
    end

    test "retrieves_instructions_append" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "# Instructions append\n\nExtra instructions for bob\n"
      assert_equal(expected, exercise.instructions_append)
    end

    test "retrieves_introduction" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "# Introduction\n\nIntroduction for bob\n"
      assert_equal(expected, exercise.introduction)
    end

    test "retrieves_introduction_append" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "# Introduction append\n\nExtra introduction for bob\n"
      assert_equal(expected, exercise.introduction_append)
    end

    test "retrieves_hints" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "# Hints\n\n## General\n\n- There are many useful string methods built-in\n"
      assert_equal(expected, exercise.hints)
    end

    test "retrieves_source" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "Inspired by the 'Deaf Grandma' exercise in Chris Pine's Learn to Program tutorial."
      assert_equal(expected, exercise.source)
    end

    test "retrieves_source_url" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = "http://pine.fm/LearnToProgram/?Chapter=06"
      assert_equal(expected, exercise.source_url)
    end

    test "retrieves_authors" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = [{ "github_username" => "erikschierboom", "exercism_username" => "ErikSchierboom" }]
      assert_equal(expected, exercise.authors)
    end

    test "retrieves_contributors" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))
      expected = [{ "github_username" => "ihid", "exercism_username" => "iHiD" }]
      assert_equal(expected, exercise.contributors)
    end
  end
end
