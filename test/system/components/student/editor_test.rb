require "application_system_test_case"

module Components
  module Student
    class EditorTest < ApplicationSystemTestCase
      test "user submits code and tests pass" do
        user = create :user
        create :user_auth_token, user: user
        solution = create :concept_solution, user: user

        visit test_components_student_editor_path(solution_id: solution.id)
        fill_in "Code", with: "Test"
        click_on "Submit"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          status: "pass",
          ops_status: 200,
          tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "Status: pass"
        assert_text "name: test_a_name_given, status: pass, output: Hello"
      end

      test "user submits code and tests fail" do
        user = create :user
        create :user_auth_token, user: user
        solution = create :concept_solution, user: user

        visit test_components_student_editor_path(solution_id: solution.id)
        fill_in "Code", with: "Test"
        click_on "Submit"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          status: "fail",
          ops_status: 200,
          tests: [{ name: :test_no_name_given, status: :fail }]
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "Status: fail"
        assert_text "name: test_no_name_given, status: fail"
      end

      test "user submits code and errors" do
        user = create :user
        create :user_auth_token, user: user
        solution = create :concept_solution, user: user

        visit test_components_student_editor_path(solution_id: solution.id)
        fill_in "Code", with: "Test"
        click_on "Submit"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          status: "error",
          message: "Undefined local variable",
          ops_status: 200,
          tests: []
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "Status: error"
        assert_text "Undefined local variable"
      end

      test "user submits code and an ops error happens" do
        user = create :user
        create :user_auth_token, user: user
        solution = create :concept_solution, user: user

        visit test_components_student_editor_path(solution_id: solution.id)
        fill_in "Code", with: "Test"
        click_on "Submit"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          status: "error",
          message: "Can't run the tests",
          ops_status: 400,
          tests: []
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "Status: ops_error"
        assert_text "Can't run the tests"
      end

      test "user submits code and cancels" do
        user = create :user
        create :user_auth_token, user: user
        solution = create :concept_solution, user: user

        visit test_components_student_editor_path(solution_id: solution.id)
        fill_in "Code", with: "Test"
        click_on "Submit"
        wait_for_submission
        click_on "Cancel"

        assert_text "Status: cancelled"
      end

      private
      def wait_for_submission
        assert_text "Status: queued", wait: 2
      end
    end
  end
end
