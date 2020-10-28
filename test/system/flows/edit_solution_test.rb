require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Components
  module Student
    class EditorTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user runs tests" do
        user = create :user
        create :user_auth_token, user: user
        solution = create :concept_solution, user: user

        visit edit_solution_path(solution.uuid)
        click_on "Run tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          status: "pass",
          ops_status: 200,
          tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "Status: pass"
        assert_text "Passed: test_a_name_given"
      end

      test "user submits code" do
        use_capybara_host do
          user = create :user
          create :user_auth_token, user: user
          solution = create :concept_solution, user: user
          submission = create :submission, solution: solution
          create :submission_test_run,
            submission: submission,
            status: "pass",
            ops_status: 200,
            tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]

          visit edit_solution_path(solution.uuid)
          click_on "Submit"

          assert_text "Iteration submitted"
        end
      end

      private
      def wait_for_submission
        assert_text "Status: queued", wait: 2
      end
    end
  end
end
