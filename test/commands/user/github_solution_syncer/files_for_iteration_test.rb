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
  end
end
