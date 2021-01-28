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

    test "non_ignored_files" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))

      assert_equal exercise.non_ignored_filepaths, exercise.non_ignored_files.keys
      assert exercise.non_ignored_files["README.md"].start_with?("README content")
    end

    test "non_ignored_filepaths" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track-with-exercises"))

      expected_filepaths = [
        "README.md",
        "bob.rb",
        "bob_test.rb",
        "subdir/more_bob.rb"
      ]
      assert_equal expected_filepaths, exercise.non_ignored_filepaths
    end
  end
end
