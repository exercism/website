require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/ace_helpers"

module Components
  class EditorTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include CodeMirrorHelpers

    test "user runs tests and tests pass with - v3 test runner" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      create :concept_solution, user: user, exercise: exercise

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 3,
            status: "pass",
            tests: [{ name: :test_a_name_given, status: :pass, output: "Hello", task_id: 1 }]
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "ALL TASKS PASSED"
      end
    end

    test "user switches files" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      submission = create :submission, solution: solution
      create :submission_file,
        submission: submission,
        content: "class LogLineParser",
        filename: "log_line_parser.rb",
        digest: Digest::SHA1.hexdigest("class LogLineParser")
      create :submission_file,
        submission: submission,
        content: "class log_line_parser_test",
        filename: "log_line_parser_test.rb",
        digest: Digest::SHA1.hexdigest("class log_line_parser_test")

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        click_on "log_line_parser_test.rb"

        assert_text "class log_line_parser_test"
        assert_no_text "class LogLineParser"
      end
    end

    test "hides hints button if there are no hints" do
      user = create :user
      track = create :track
      exercise = create :practice_exercise, track: track, slug: "allergies"
      create :user_track, track: track, user: user
      create :practice_solution, user: user, exercise: exercise

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
      end

      assert_no_css ".hints-btn"
    end

    test "user switches to instructions tab" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      create :concept_solution, user: user, exercise: exercise

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)

        click_on "Instructions"

        assert_text "How to debug"
      end
    end

    test "hide feedback tab when there are iterations" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      # running test
      submission = create :submission, solution: solution
      create :submission_file,
        submission: submission,
        content: "class LogLineParser",
        filename: "log_line_parser.rb",
        digest: Digest::SHA1.hexdigest("class LogLineParser")

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)

        refute_text "Feedback"
      end
    end

    test "show feedback tab and request message when there is no automated nor mentor feedback" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      submission = create :submission, solution: solution
      create :submission_file,
        submission: submission,
        content: "class LogLineParser",
        filename: "log_line_parser.rb",
        digest: Digest::SHA1.hexdigest("class LogLineParser")
      create :iteration, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)

        # Make sure component is mounted
        sleep 0.5
        click_on "Feedback"

        assert_text "Take your solution to the next level"
      end
    end

    test "feedback panel shows automated feedback details when submission has representer feedback" do
      user = create :user
      mentor = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      submission = create :submission, solution: solution,
        tests_status: :passed,
        representation_status: :generated,
        analysis_status: :completed
      create :submission_test_run,
        submission: submission,
        ops_status: 200,
        raw_results: {
          version: 2,
          status: "pass",
          tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
        }
      create :iteration, solution: solution, submission: submission, idx: 1
      create :submission_file, submission: submission

      create :exercise_representation,
        exercise: exercise,
        source_submission: submission,
        feedback_author: mentor,
        feedback_markdown: "Some representer feedback",
        feedback_type: :essential,
        ast_digest: "AST"
      create :submission_representation, submission: submission, ast_digest: "AST"

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)

        sleep 0.5
        click_on "Feedback"
        refute_text "Mentoring Discussion"
        assert_text "Automated Feedback"
        # click_on can only click on links or buttons
        find("details", text: "Automated Feedback").click
        assert_text "Some representer feedback"
      end
    end

    test "feedback panel shows automated feedback details when submission has analyzer feedback" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      submission = create :submission, solution: solution,
        tests_status: :passed,
        representation_status: :generated,
        analysis_status: :completed
      create :submission_test_run,
        submission: submission,
        ops_status: 200,
        raw_results: {
          version: 2,
          status: "pass",
          tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
        }
      create :iteration, solution: solution, submission: submission, idx: 1
      create :submission_file, submission: submission
      create :submission_analysis, submission: submission, data: {
        comments: [
          { type: "essential", comment: "ruby.two-fer.splat_args" }
        ]
      }

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)

        sleep 0.5
        click_on "Feedback"
        refute_text "Mentoring Discussion"
        assert_text "Automated Feedback"
        # click_on can only click on links or buttons
        find("details", text: "Automated Feedback").click
        assert_text "Our Ruby Analyzer has some comments"
      end
    end

    test "feedback panel shows mentoring discussion details" do
      user = create :user
      mentor = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      submission = create :submission, solution: solution,
        tests_status: :passed,
        representation_status: :generated,
        analysis_status: :completed
      create :submission_test_run,
        submission: submission,
        ops_status: 200,
        raw_results: {
          version: 2,
          status: "pass",
          tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
        }
      create :iteration, solution: solution, submission: submission, idx: 1
      create :submission_file, submission: submission
      create :mentor_discussion, solution: solution, mentor: mentor

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)

        sleep 0.5
        click_on "Feedback"
        assert_text "Mentoring Discussion"
        refute_text "Automated Feedback"
        # click_on can only click on links or buttons
        find("details", text: "Mentoring Discussion").click
        assert_text "This is your latest mentoring session"
        assert_css "img[src='#{user.avatar_url}']"\
        "[alt=\"Uploaded avatar of #{user.handle}\"]"
        assert_text "Iteration 1"
      end
    end

    test "feedback panel shows automated feedback and mentoring discussion details" do
      user = create :user
      mentor = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      # run tests
      submission = create :submission, solution: solution,
        tests_status: :passed,
        representation_status: :generated,
        analysis_status: :completed
      # tests passed
      # click on submit
      create :submission_test_run,
        submission: submission,
        ops_status: 200,
        raw_results: {
          version: 2,
          status: "pass",
          tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
        }
      # itertation is created
      create :iteration, solution: solution, submission: submission, idx: 1
      create :submission_file, submission: submission
      create :submission_analysis, submission: submission, data: {
        comments: [
          { type: "essential", comment: "ruby.two-fer.splat_args" }
        ]
      }
      create :exercise_representation,
        exercise: exercise,
        source_submission: submission,
        feedback_author: mentor,
        feedback_markdown: "Representer feedback",
        feedback_type: :essential,
        ast_digest: "AST"
      create :submission_representation, submission: submission, ast_digest: "AST"
      create :mentor_discussion, solution: solution, mentor: mentor

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)

        sleep 0.5
        click_on "Feedback"
        assert_text "Mentoring Discussion"
        assert_text "Automated Feedback"
        # click_on can only click on links or buttons
        find("details", text: "Automated Feedback").click
        find("details", text: "Mentoring Discussion").click
        assert_text "Our Ruby Analyzer has some comments"
        assert_text "This is your latest mentoring session"
        assert_text "Representer feedback"
        assert_css "img[src='#{user.avatar_url}']"\
        "[alt=\"Uploaded avatar of #{user.handle}\"]"
        assert_text "Iteration 1"
      end
    end

    test "user runs tests and tests pass - v2 test runner" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      create :concept_solution, user: user, exercise: exercise

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 2,
            status: "pass",
            tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "ALL TESTS PASSED"
        assert_text "1 test passed"
      end
    end

    test "user runs tests and tests pass with - v1 test runner" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      create :concept_solution, user: user, exercise: exercise

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 1,
            status: "pass"
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "ALL TESTS PASSED"
      end
    end

    test "user gets tests results even if websockets broadcast fails" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      create :concept_solution, user: user, exercise: exercise

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 2,
            status: "pass",
            tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
          }

        assert_text "1 test passed"
      end
    end

    test "user runs tests and tests fail - v3 test runner" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      create :concept_solution, user: user, exercise: exercise

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 3,
            status: "fail",
            tests: [{ name: :test_no_name_given, status: :fail, task_id: 1 }]
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "2 / 3 Tasks Completed"
      end
    end

    test "user runs tests and tests fail - v2 test runner" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      create :concept_solution, user: user, exercise: exercise

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 2,
            status: "fail",
            tests: [{ name: :test_no_name_given, status: :fail }]
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "1 TEST FAILURE"
        assert_text "1 test failed"
      end
    end

    test "user runs tests and tests fail - v1 test runner" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      create :concept_solution, user: user, exercise: exercise

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        message = "Oh dear Foobar - here is some stuff"
        test_run = create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 1,
            status: "fail",
            message:
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "TESTS FAILED"
        assert_text message
      end
    end

    test "user runs tests and errors" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      create :concept_solution, user: user, exercise: exercise

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          message: "Undefined local variable",
          ops_status: 200,
          raw_results: {
            version: 2,
            status: "error",
            tests: []
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "AN ERROR OCCURRED"
        assert_text "Undefined local variable"
      end
    end

    test "user runs tests and an ops error happens" do
      expecting_errors do
        user = create :user
        track = create :track
        exercise = create :concept_exercise, track: track
        create :user_track, track: track, user: user
        create :concept_solution, user: user, exercise: exercise

        use_capybara_host do
          sign_in!(user)
          visit edit_track_exercise_path(track, exercise)
          fill_in_editor "test"
          click_on "Run Tests"
          wait_for_submission
          2.times { wait_for_websockets }
          test_run = create :submission_test_run,
            submission: Submission.last,
            message: "Can't run the tests",
            ops_status: 400,
            raw_results: {
              version: 2,
              status: "error",
              tests: []
            }
          Submission::TestRunsChannel.broadcast!(test_run)

          assert_text "AN ERROR OCCURRED"
          assert_text "An error occurred while running your tests"
        end
      end
    end

    test "user runs tests and cancels" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      submission = create :submission, solution: solution
      test_run = create :submission_test_run,
        submission: submission,
        ops_status: 200,
        raw_results: {
          version: 2,
          status: "fail",
          tests: [{ name: :test_no_name_given, status: :fail }]
        }

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        click_on "Cancel"
        assert_text "Test run cancelled"
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          message: "Can't run the tests",
          ops_status: 400,
          raw_results: {
            version: 2,
            status: "error",
            tests: []
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_no_text "AN ERROR OCCURRED"
        assert_text "Test run cancelled"
        assert_text "1 test failed"
      end
    end

    test "user sees previous test results - v3 test runner" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      submission = create :submission, solution: solution
      create :submission_test_run,
        submission: submission,
        ops_status: 200,
        raw_results: {
          version: 3,
          status: "pass",
          tests: [{ name: :test_a_name_given, status: :pass, output: "Hello", task_id: 1 }]
        }

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)

        assert_text "ALL TASKS PASSED"
      end
    end

    test "user sees previous test results - v2 test runner" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      submission = create :submission, solution: solution
      create :submission_test_run,
        submission: submission,
        ops_status: 200,
        raw_results: {
          version: 2,
          status: "pass",
          tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
        }

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)

        assert_text "1 test passed"
      end
    end

    test "user reverts to last iteration" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      submission = create :submission, solution: solution
      create :submission_file,
        submission: submission,
        content: "old content",
        filename: "log_line_parser.rb",
        digest: Digest::SHA1.hexdigest("old content")
      create :iteration, submission: submission
      submission = create :submission, solution: solution
      create :submission_file,
        submission: submission,
        content: "new content",
        filename: "log_line_parser.rb",
        digest: Digest::SHA1.hexdigest("new content")

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        find(".more-btn").click
        click_on("Revert to last iteration")

        assert_text "old content"
      end
    end

    test "user reverts to original exercise solution" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      submission = create :submission, solution: solution
      create :submission_file,
        submission: submission,
        content: "new content",
        filename: "log_line_parser.rb",
        digest: Digest::SHA1.hexdigest("new content")

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        find(".more-btn").click
        click_on("Revert to exercise start")

        assert_text "Please implement the LogLineParser.message method"
      end
    end

    test "user views hints" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      create :concept_solution, user: user, exercise: exercise

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        click_on "Stuck? Reveal Hints"

        within(".m-editor-hints") { assert_text "Get message from a log line" }
      end
    end

    test "user deletes legacy files" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      create :user_track, track: track, user: user
      solution = create :concept_solution, user: user, exercise: exercise
      submission = create :submission, solution: solution
      create :submission_file, submission: submission, filename: "log_line_parser.rb", content: "foobar1"
      create :submission_file, submission: submission, filename: "something_else.rb", content: "foobar2"

      use_capybara_host do
        sign_in!(user)
        visit edit_track_exercise_path(track, exercise)
        click_on "log_line_parser.rb"
        fill_in_editor "this should remain"

        click_on "something_else.rb"
        click_on "Delete file"
        within(".m-generic-confirmation") { click_on "Delete file" }

        assert_no_text "something_else.rb"
        assert_text "log_line_parser.rb"
        assert_text "this should remain"
      end
    end

    private
    def wait_for_submission
      assert_text "Running tests..."
    end
  end
end
