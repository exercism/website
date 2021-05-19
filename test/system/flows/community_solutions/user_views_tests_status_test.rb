require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module CommunitySolutions
    class UserViewsTestsStatusTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user views test status" do
        track = create :track
        exercise = create :concept_exercise, track: track
        author = create :user, handle: "author"
        solution = create :concept_solution, :completed, :published, user: author, exercise: exercise
        submission = create :submission, solution: solution, tests_status: :failed
        create :iteration, submission: submission
        create :submission_test_run,
          submission: submission,
          status: "fail",
          ops_status: 200,
          raw_results: {
            version: 3,
            tests: [{ name: :test_no_name_given, status: :fail, task_id: 1 }]
          }

        use_capybara_host do
          sign_in!
          visit track_exercise_community_solution_url(track, exercise, "author")
          click_on "Failed"

          assert_text "1 test failed"
        end
      end
    end
  end
end
