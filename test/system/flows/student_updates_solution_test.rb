require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require 'sidekiq/testing'

module Flows
  class StudentUpdatesSolutionTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "student updates solution" do
      user = create :user
      track = create :track
      create(:user_track, user:, track:)
      exercise = create :concept_exercise,
        track:,
        slug: "lasagna",
        git_sha: "bc42eeda40b3d99a0379cd88a3bbbd0a12bce50a",
        git_important_files_hash: "cd65371ae91f57453b8a278998db1815afb41e7c"
      create(:concept_solution,
        git_sha: "ac388147339875555f9df49d783d477492bebcf3",
        git_important_files_hash: "a75ab88416d5e437c0cef036ae557d653b41ca1b",
        exercise:,
        user:)

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_path(track, exercise)
        click_on "This exercise has been updated"

        assert_text "lasagna_test.rb"
        assert_text "def test_total_time_in_minutes_for_multiple_layer"

        click_on "Update exercise"

        assert_no_text "This exercise has been updated"
      end
    end

    test "students solution is automatically updated if the tests pass" do
      old_git_sha = "ac388147339875555f9df49d783d477492bebcf3"
      new_git_sha = "bc42eeda40b3d99a0379cd88a3bbbd0a12bce50a"
      solution, submission = setup_update_scenario(old_git_sha, new_git_sha)

      # Stimulate a successful test run
      job = Exercism::ToolingJob.find_for_submission_uuid_and_type(submission.uuid, :test_runner)
      execution_output = { 'results.json' => { 'status' => 'pass', 'message' => "", 'tests' => [] }.to_json }
      job.executed!(200, execution_output)
      job = Exercism::ToolingJob.find_for_submission_uuid_and_type(submission.uuid, :test_runner)

      # Now process and check that it's updated correctly
      Submission::TestRun::Process.(job)

      assert_equal new_git_sha, solution.reload.git_sha
    end

    test "students solution is not automatically updated if the tests fail" do
      old_git_sha = "ac388147339875555f9df49d783d477492bebcf3"
      new_git_sha = "bc42eeda40b3d99a0379cd88a3bbbd0a12bce50a"
      solution, submission = setup_update_scenario(old_git_sha, new_git_sha)

      # Stimulate a successful test run
      job = Exercism::ToolingJob.find_for_submission_uuid_and_type(submission.uuid, :test_runner)
      job.executed!(400, {})
      job = Exercism::ToolingJob.find_for_submission_uuid_and_type(submission.uuid, :test_runner)

      # Now process and check that it's updated correctly
      Submission::TestRun::Process.(job)

      assert_equal old_git_sha, solution.reload.git_sha
    end

    private
    def setup_update_scenario(old_git_sha, new_git_sha)
      user = create :user
      track = create :track
      create(:user_track, user:, track:)
      exercise = create :concept_exercise,
        track:,
        slug: "lasagna",
        git_sha: old_git_sha,
        git_important_files_hash: "a75ab88416d5e437c0cef036ae557d653b41ca1b"
      solution = create(:concept_solution, exercise:, user:)
      submission = create(:submission, solution:)
      create(:iteration, submission:, solution:)

      # Make sure we're in a state that means we don't just work through
      # because the tests pass for the first time
      solution.update!(latest_iteration_head_tests_status: :passed)

      Sidekiq::Queues.clear_all

      exercise.update(git_sha: new_git_sha)
      3.times { perform_enqueued_jobs }

      [solution, submission]
    end
  end
end
