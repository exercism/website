require "test_helper"

class User::GithubSolutionSyncer
  class FilesForIterationTest < ActiveSupport::TestCase
    test "selects files for iteration" do
      user = create(:user)
      track = create(:track, title: "Ruby", slug: "ruby")
      exercise = create(:practice_exercise, title: "Two Fer", slug: "two-fer", track:)
      solution = create(:practice_solution, user:, exercise:)
      submission = create(:submission)
      create(:submission_file, submission:, filename: "two_fer.rb", content: "puts 'hi'")
      create(:submission_file, submission:, filename: "README.md", content: "# Two Fer")
      iteration = create(:iteration, user:, solution:, idx: 3, submission:)

      syncer = create(
        :user_github_solution_syncer,
        user:,
        path_template: "solutions/$track_slug/$exercise_slug/$iteration_idx"
      )

      expected = [
        {
          path: "solutions/ruby/two-fer/3/two_fer.rb",
          mode: "100644",
          type: "blob",
          content: "puts 'hi'"
        },
        {
          path: "solutions/ruby/two-fer/3/README.md",
          mode: "100644",
          type: "blob",
          content: "# Two Fer"
        }
      ]
      actual = FilesForIteration.(syncer, iteration)
      assert_equal expected, actual
    end

    test "include solution files if requested" do
      user = create(:user)
      exercise = create(:practice_exercise)
      solution = create(:practice_solution, user:, exercise:)
      submission = create(:submission)
      create(:submission_file, submission:, filename: "bob.rb", content: "puts 'hi'")
      iteration = create(:iteration, user:, solution:, idx: 3, submission:)

      syncer = create(
        :user_github_solution_syncer,
        user:,
        path_template: "solutions/$track_slug/$exercise_slug/$iteration_idx",
        sync_exercise_files: true
      )

      expected = [
        { path: "solutions/ruby/bob/3/README.md", mode: "100644", type: "blob", content: readme },
        { path: "solutions/ruby/bob/3/HELP.md", mode: "100644", type: "blob", content: help },
        { path: "solutions/ruby/bob/3/HINTS.md", mode: "100644", type: "blob", content: hints },
        { path: "solutions/ruby/bob/3/bob.rb", mode: "100644", type: "blob", content: "puts 'hi'" },
        { path: "solutions/ruby/bob/3/bob_test.rb", mode: "100644", type: "blob", content: "test content\n" },
        { path: "solutions/ruby/bob/3/subdir/more_bob.rb", mode: "100644", type: "blob", content: "Some subdir content\n" }
      ]
      actual = FilesForIteration.(syncer, iteration)
      assert_equal expected, actual
    end

    # rubocop:disable Naming/HeredocDelimiterNaming
    def readme = <<~EOS.strip
      # Bob

      Welcome to Bob on Exercism's Ruby Track.
      If you need help running the tests or submitting your code, check out `HELP.md`.
      If you get stuck on the exercise, check out `HINTS.md`, but try and solve it without using those first :)

      ## Introduction

      Introduction for bob

      Extra introduction for bob

      ## Instructions

      Instructions for bob

      Extra instructions for bob

      ## Source

      ### Created by

      - @erikschierboom

      ### Contributed to by

      - @ihid

      ### Based on

      Inspired by the 'Deaf Grandma' exercise in Chris Pine's Learn to Program tutorial. - http://pine.fm/LearnToProgram/?Chapter=06
    EOS

    def help = <<~EOS.strip
      # Help

      ## Running the tests

      Run the tests using `ruby test`.

      ## Submitting your solution

      You can submit your solution using the `exercism submit bob.rb` command.
      This command will upload your solution to the Exercism website and print the solution page's URL.

      It's possible to submit an incomplete solution which allows you to:

      - See how others have completed the exercise
      - Request help from a mentor

      ## Need to get help?

      If you'd like help solving the exercise, check the following pages:

      - The [Ruby track's documentation](https://exercism.org/docs/tracks/ruby)
      - The [Ruby track's programming category on the forum](https://forum.exercism.org/c/programming/ruby)
      - [Exercism's programming category on the forum](https://forum.exercism.org/c/programming/5)
      - The [Frequently Asked Questions](https://exercism.org/docs/using/faqs)

      Should those resources not suffice, you could submit your (incomplete) solution to request mentoring.

      Stuck? Try the Ruby gitter channel.
    EOS

    def hints = <<~EOS.strip
      # Hints

      ## General

      - There are many useful string methods built-in
    EOS
  end
  # rubocop:enable Naming/HeredocDelimiterNaming
end
