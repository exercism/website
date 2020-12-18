require 'test_helper'

module Git
  class ExerciseTest < ActiveSupport::TestCase
    test "editor_solution_files" do
      exercise = Git::Exercise.new(:ruby, :bob, "practice", "HEAD")

      expected_files = ["bob.rb"]
      assert_equal expected_files, exercise.editor_solution_files.keys
      assert exercise.editor_solution_files["bob.rb"].start_with?("stub content\n")
    end

    test "read_file_blob" do
      exercise = Git::Exercise.new(:ruby, :bob, "practice", "HEAD")

      assert_equal "stub content\n", exercise.read_file_blob('bob.rb')
    end

    test "non_ignored_files" do
      exercise = Git::Exercise.new(:csharp, :datetime, "concept", "HEAD")

      assert_equal exercise.non_ignored_filepaths, exercise.non_ignored_files.keys
      assert exercise.non_ignored_files[".docs/hints.md"].start_with?("## General")
    end

    test "non_ignored_filepaths" do
      exercise = Git::Exercise.new(:csharp, :datetime, "concept", "HEAD")

      expected_filepaths = [
        ".docs/hints.md",
        ".docs/instructions.md",
        ".docs/introduction.md",
        ".meta/config.json",
        "README.md",
        "bob.rb",
        "bob_test.rb",
        "subdir/more_bob.rb"
      ]
      assert_equal expected_filepaths, exercise.non_ignored_filepaths
    end
  end
end
