require 'test_helper'

module Git
  class ExerciseTest < ActiveSupport::TestCase
    test "files_for_editor" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_files = ["log_line_parser.rb"]
      assert_equal expected_files, exercise.files_for_editor.keys
      assert exercise.files_for_editor["log_line_parser.rb"][:content].start_with?("module LogLineParser")
    end

    test "read_file_blob" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      assert_equal "stub content\n", exercise.read_file_blob('bob.rb')
    end

    test "solution_filepaths" do
      exercise = Git::Exercise.new(:satellite, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = ["satellite.rb"]
      assert_equal(expected, exercise.solution_filepaths)
    end

    test "test_filepaths" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = ["bob_test.rb"]
      assert_equal(expected, exercise.test_filepaths)
    end

    test "editor_filepaths" do
      exercise = Git::Exercise.new(:isogram, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = ["helper.rb"]
      assert_equal(expected, exercise.editor_filepaths)
    end

    test "invalidator_filepaths" do
      exercise = Git::Exercise.new(:hamming, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = ["rubocop.yml"]
      assert_equal(expected, exercise.invalidator_filepaths)
    end

    test "example_filepaths" do
      exercise = Git::Exercise.new(:anagram, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = [".meta/example.rb"]
      assert_equal(expected, exercise.example_filepaths)
    end

    test "exemplar_filepaths" do
      exercise = Git::Exercise.new(:booleans, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = [".meta/exemplar.rb"]
      assert_equal(expected, exercise.exemplar_filepaths)
    end

    test "tooling_files" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      assert_equal exercise.tooling_filepaths, exercise.tooling_files.keys
      assert exercise.tooling_files["bob.rb"].start_with?("stub content")
    end

    test "tooling_filepaths" do
      exercise = Git::Exercise.new(:allergies, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".meta/config.json",
        ".meta/example.rb",
        "allergies.rb",
        "allergies_test.rb"
      ]
      assert_equal expected_filepaths, exercise.tooling_filepaths
    end

    test "tooling_filepaths with editor files" do
      exercise = Git::Exercise.new(:isogram, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".meta/config.json",
        ".meta/example.rb",
        "helper.rb",
        "isogram.rb",
        "isogram_test.rb"
      ]
      assert_equal expected_filepaths, exercise.tooling_filepaths
    end

    test "tooling_filepaths with invalidator files" do
      exercise = Git::Exercise.new(:hamming, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".meta/config.json",
        ".meta/example.rb",
        "hamming.rb",
        "hamming_test.rb",
        "rubocop.yml"
      ]
      assert_equal expected_filepaths, exercise.tooling_filepaths
    end

    test "tooling_filepaths with approaches files" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".meta/config.json",
        ".meta/example.rb",
        "bob.rb",
        "bob_test.rb",
        "subdir/more_bob.rb"
      ]
      assert_equal expected_filepaths, exercise.tooling_filepaths
    end

    test "tooling_filepaths with articles files" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
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
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".exercism/config.json",
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
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".exercism/config.json",
        "README.md",
        "HELP.md",
        "anagram.rb",
        "anagram_test.rb"
      ]
      assert_equal expected_filepaths, exercise.cli_filepaths
    end

    test "cli_filepaths excludes exemplar files outside hidden dirs" do
      exercise = Git::Exercise.new(:numbers, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".exercism/config.json",
        "README.md",
        "HELP.md",
        "HINTS.md",
        "assembly_line.rb",
        "assembly_line_test.rb"
      ]
      assert_equal expected_filepaths, exercise.cli_filepaths
    end

    test "cli_filepaths excludes example files outside hidden dirs" do
      exercise = Git::Exercise.new(:leap, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".exercism/config.json",
        "README.md",
        "HELP.md",
        "leap.rb",
        "leap_test.rb",
        "rubocop.yml"
      ]
      assert_equal expected_filepaths, exercise.cli_filepaths
    end

    test "cli_filepaths with approaches" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".exercism/config.json",
        "README.md",
        "HELP.md",
        "HINTS.md",
        "bob.rb",
        "bob_test.rb",
        "subdir/more_bob.rb"
      ]
      assert_equal expected_filepaths, exercise.cli_filepaths
    end

    test "important_filepaths without appends" do
      exercise = Git::Exercise.new(:anagram, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".docs/instructions.md",
        "anagram_test.rb"
      ]
      assert_equal expected_filepaths, exercise.important_filepaths
    end

    test "important_filepaths with appends" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".docs/instructions.md",
        ".docs/instructions.append.md",
        ".docs/introduction.md",
        ".docs/introduction.append.md",
        ".docs/hints.md",
        "bob_test.rb"
      ]
      assert_equal expected_filepaths, exercise.important_filepaths
    end

    test "important_filepaths with editor files" do
      exercise = Git::Exercise.new(:isogram, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".docs/instructions.md",
        "isogram_test.rb",
        "helper.rb"
      ]
      assert_equal expected_filepaths, exercise.important_filepaths
    end

    test "important_filepaths with invalidator files" do
      exercise = Git::Exercise.new(:hamming, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".docs/instructions.md",
        "hamming_test.rb",
        "rubocop.yml"
      ]
      assert_equal expected_filepaths, exercise.important_filepaths
    end

    test "important_filepaths with approaches" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      expected_filepaths = [
        ".docs/instructions.md",
        ".docs/instructions.append.md",
        ".docs/introduction.md",
        ".docs/introduction.append.md",
        ".docs/hints.md",
        "bob_test.rb"
      ]
      assert_equal expected_filepaths, exercise.important_filepaths
    end

    test "valid_filepaths" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      assert exercise.valid_submission_filepath?('bob.rb')
      assert exercise.valid_submission_filepath?('subdir/more_bob.rb')
      refute exercise.valid_submission_filepath?('bob_test.rb')
      refute exercise.valid_submission_filepath?('.meta/config.json')
      refute exercise.valid_submission_filepath?('.meta/example.rb')
      refute exercise.valid_submission_filepath?('.docs/instructions.md')
    end

    test "valid_filepaths with editor files" do
      exercise = Git::Exercise.new(:isogram, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      assert exercise.valid_submission_filepath?('isogram.rb')
      assert exercise.valid_submission_filepath?('subdir/more_isogram.rb')
      refute exercise.valid_submission_filepath?('helper.rb')
      refute exercise.valid_submission_filepath?('isogram_test.rb')
      refute exercise.valid_submission_filepath?('.meta/config.json')
      refute exercise.valid_submission_filepath?('.meta/example.rb')
      refute exercise.valid_submission_filepath?('.docs/instructions.md')
    end

    test "retrieves instructions" do
      exercise = Git::Exercise.new(:isogram, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = "# Instructions\n\nInstructions for isogram"
      assert_equal(expected, exercise.instructions)
    end

    test "retrieves instructions with append" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = "# Instructions\n\nInstructions for bob\n\n# Instructions append\n\nExtra instructions for bob"
      assert_equal(expected, exercise.instructions)
    end

    test "retrieves introduction" do
      exercise = Git::Exercise.new("space-age", "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = "# Introduction\n\nIntroduction for space-age"
      assert_equal(expected, exercise.introduction)
    end

    test "retrieves introduction with append" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = "# Introduction\n\nIntroduction for bob\n\n# Introduction append\n\nExtra introduction for bob"
      assert_equal(expected, exercise.introduction)
    end

    test "retrieves hints" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = "# Hints\n\n## General\n\n- There are many useful string methods built-in"
      assert_equal(expected, exercise.hints)
    end

    test "retrieves source" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = "Inspired by the 'Deaf Grandma' exercise in Chris Pine's Learn to Program tutorial."
      assert_equal(expected, exercise.source)
    end

    test "retrieves source_url" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = "http://pine.fm/LearnToProgram/?Chapter=06"
      assert_equal(expected, exercise.source_url)
    end

    test "retrieves icon_name" do
      exercise = Git::Exercise.new(:isogram, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal("iso", exercise.icon_name)
    end

    test "use slug as icon_name if not present" do
      exercise = Git::Exercise.new(:allergies, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal("allergies", exercise.icon_name)
    end

    test "authors" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal(["erikschierboom"], exercise.authors)
    end

    test "contributors" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal(["ihid"], exercise.contributors)
    end

    test "contributors for exercise without contributors" do
      exercise = Git::Exercise.new(:allergies, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_empty(exercise.contributors)
    end

    test "example files" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = { ".meta/example.rb" => "example content for bob\n" }
      assert_equal(expected, exercise.example_files)
    end

    test "test_files" do
      exercise = Git::Exercise.new(:bob, "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = { "bob_test.rb" => "test content\n" }
      assert_equal(expected, exercise.test_files)
    end

    test "exemplar files" do
      exercise = Git::Exercise.new(:lasagna, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      expected = { ".meta/exemplar.rb" => "class Lasagna\n  EXPECTED_MINUTES_IN_OVEN = 40\n  PREPARATION_MINUTES_PER_LAYER = 2\n\n  def remaining_minutes_in_oven(actual_minutes_in_oven)\n    EXPECTED_MINUTES_IN_OVEN - actual_minutes_in_oven\n  end\n\n  def preparation_time_in_minutes(layers)\n    layers * PREPARATION_MINUTES_PER_LAYER\n  end\n\n  def total_time_in_minutes(number_of_layers:, actual_minutes_in_oven:)\n    preparation_time_in_minutes(number_of_layers) + actual_minutes_in_oven\n  end\nend\n" } # rubocop:disable Layout/LineLength
      assert_equal(expected, exercise.exemplar_files)
    end

    test "instructions file path" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('.docs/instructions.md', exercise.instructions_filepath)
    end

    test "instructions absolute file path" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/concept/strings/.docs/instructions.md', exercise.instructions_absolute_filepath)
    end

    test "instructions_append file path" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('.docs/instructions.append.md', exercise.instructions_append_filepath)
    end

    test "instructions_append absolute file path" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/concept/strings/.docs/instructions.append.md', exercise.instructions_append_absolute_filepath)
    end

    test "introduction file path" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('.docs/introduction.md', exercise.introduction_filepath)
    end

    test "introduction absolute file path" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/concept/strings/.docs/introduction.md', exercise.introduction_absolute_filepath)
    end

    test "introduction_append file path" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('.docs/introduction.append.md', exercise.introduction_append_filepath)
    end

    test "introduction_append absolute file path" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/concept/strings/.docs/introduction.append.md', exercise.introduction_append_absolute_filepath)
    end

    test "hints file path" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('.docs/hints.md', exercise.hints_filepath)
    end

    test "hints absolute file path" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/concept/strings/.docs/hints.md', exercise.hints_absolute_filepath)
    end

    test "config file path" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('.meta/config.json', exercise.config_filepath)
    end

    test "config absolute file path" do
      exercise = Git::Exercise.new(:strings, "concept", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))
      assert_equal('exercises/concept/strings/.meta/config.json', exercise.config_absolute_filepath)
    end

    test "representer_version" do
      exercise = Git::Exercise.new('space-age', "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      assert_equal 2, exercise.representer_version
    end

    test "representer_version defaults to 1 if it doesn't exist" do
      exercise = Git::Exercise.new('bob', "practice", "HEAD",
        repo_url: TestHelpers.git_repo_url("track"))

      assert_equal 1, exercise.representer_version
    end
  end
end
