require "test_helper"

class User::GithubSolutionSyncer
  class GeneratePullRequestTitleTest < ActiveSupport::TestCase
    test "generates basic string" do
      template = "Hello world!"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "Hello world!"
      actual = GeneratePullRequestTitle.(syncer, "Iteration")
      assert_equal expected, actual
    end

    test "interpolates sync object" do
      template = "Syncing $sync_object"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "Syncing Iteration"
      actual = GeneratePullRequestTitle.(syncer, "Iteration")
      assert_equal expected, actual
    end

    test "interpolates track details" do
      track = create(:track)
      template = "Syncing $track_title $track_slug"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "Syncing #{track.title} #{track.slug}"
      actual = GeneratePullRequestTitle.(syncer, "Iteration", track:)
      assert_equal expected, actual
    end

    test "interpolates exercise details and infers track" do
      track = create(:track)
      exercise = create(:practice_exercise, track:)
      template = "Syncing $track_title $track_slug $exercise_title $exercise_slug"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "Syncing #{track.title} #{track.slug} #{exercise.title} #{exercise.slug}"
      actual = GeneratePullRequestTitle.(syncer, "Iteration", exercise:)
      assert_equal expected, actual
    end

    test "interpolates iteration details and infers track and exercise" do
      track = create(:track)
      exercise = create(:practice_exercise, track:)
      iteration = create(:iteration, idx: 3, exercise:)
      template = "Syncing $track_title $track_slug $exercise_title $exercise_slug $iteration_idx"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "Syncing #{track.title} #{track.slug} #{exercise.title} #{exercise.slug} 3"
      actual = GeneratePullRequestTitle.(syncer, "Iteration", iteration:)
      assert_equal expected, actual
    end

    test "cleans up double slashes" do
      template = "Something // else"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "Something / else"
      actual = GeneratePullRequestTitle.(syncer, "Something")
      assert_equal expected, actual
    end

    test "cleans up triple slashes" do
      template = "Something /// else"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "Something / else"
      actual = GeneratePullRequestTitle.(syncer, "Something")
      assert_equal expected, actual
    end

    test "removes leading and trailing slashes" do
      template = "/leading/slash/ and trailing/slash/"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "leading/slash/ and trailing/slash"
      actual = GeneratePullRequestTitle.(syncer, "Something")
      assert_equal expected, actual
    end

    test "removes leading and trailing dashes" do
      template = "-leading-dash- and trailing-dash-"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "leading-dash- and trailing-dash"
      actual = GeneratePullRequestTitle.(syncer, "Something")
      assert_equal expected, actual
    end

    test "cleans up slashes seperated by spaces" do
      template = "Something / / / else"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "Something / else"
      actual = GeneratePullRequestTitle.(syncer, "Something")
      assert_equal expected, actual
    end

    test "cleans up double dashes" do
      template = "Something -- else"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "Something - else"
      actual = GeneratePullRequestTitle.(syncer, "Something")
      assert_equal expected, actual
    end

    test "cleans up triple dashes" do
      template = "Something --- else"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "Something - else"
      actual = GeneratePullRequestTitle.(syncer, "Something")
      assert_equal expected, actual
    end

    test "cleans up dashes seperated by spaces" do
      template = "Something - - - else"
      syncer = create(:user_github_solution_syncer, commit_message_template: template)

      expected = "Something - else"
      actual = GeneratePullRequestTitle.(syncer, "Something")
      assert_equal expected, actual
    end
  end
end
