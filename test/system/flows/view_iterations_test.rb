require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class ViewIterationsTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "responds to websockets" do
      Submission::File.any_instance.stubs(:content)
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user
      submission = create :submission, tests_status: :queued, solution: solution, submitted_via: :cli
      create :iteration, idx: 2, solution: solution, submission: submission
      create :submission_file, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)

        assert_text "Iteration 2"
        assert_text "Processing"

        submission.update!(tests_status: :failed)
        SolutionChannel.broadcast!(solution)
        assert_text "Failed"
      end
    end

    test "opens and closes iterations as expected" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user

      submission_1 = create :submission, tests_status: :queued, solution: solution
      create :iteration, idx: 1, solution: solution, submission: submission_1
      create :submission_file, submission: submission_1

      submission_2 = create :submission, tests_status: :queued, solution: solution
      create :iteration, idx: 2, solution: solution, submission: submission_2
      create :submission_file, submission: submission_2

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)

        assert_equal "true", find("details", text: "Iteration 2")['open']
        assert_equal "false", find("details", text: "Iteration 1")['open']

        find("summary", text: "Iteration 2").click
        assert_equal "false", find("details", text: "Iteration 2")['open']
        assert_equal "false", find("details", text: "Iteration 1")['open']

        find("summary", text: "Iteration 2").click
        assert_equal "true", find("details", text: "Iteration 2")['open']
        assert_equal "false", find("details", text: "Iteration 1")['open']

        find("summary", text: "Iteration 1").click
        assert_equal "true", find("details", text: "Iteration 2")['open']
        assert_equal "true", find("details", text: "Iteration 1")['open']
      end
    end

    test "opens newest iteration when there are no iterations open" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user
      submission = create :submission, tests_status: :queued, solution: solution, submitted_via: :cli
      create :iteration, idx: 2, solution: solution, submission: submission
      create :submission_file, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)
        find("summary").click

        create :iteration, idx: 3, solution: solution
        SolutionChannel.broadcast!(solution)
        assert_equal find("details", text: "Iteration 3")['open'], "true"
      end
    end

    test "does not open newest iteration when there are iterations open" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      create :hello_world_solution, :completed, track: track, user: user

      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user
      submission = create :submission, tests_status: :queued, solution: solution, submitted_via: :cli
      create :iteration, idx: 2, solution: solution, submission: submission
      create :submission_file, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)
        sleep(0.1) # Give the websockets time to attach

        create :iteration, idx: 3, solution: solution
        SolutionChannel.broadcast!(solution)

        assert_equal "false", find("details", text: "Iteration 3")['open']
      end
    end

    test "user sees zero state" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      create :concept_solution, exercise: exercise, user: user

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)

        assert_text "You haven’t submitted any iterations yet."
      end
    end

    test "user starts exercise in zero state" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      create :concept_solution, exercise: exercise, user: user

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)
        click_on "Start in Editor"

        assert_text "Introduction"
      end
    end

    test "user views iteration files" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user
      submission = create :submission, tests_status: :queued, solution: solution, submitted_via: :cli
      create :iteration, idx: 2, solution: solution, submission: submission
      create :submission_file, submission: submission, content: "class Bob\n"

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)

        assert_text "class Bob"
      end
    end

    test "user views processing iteration" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user
      submission = create :submission, tests_status: :queued, solution: solution
      create :iteration, solution: solution, submission: submission
      create :submission_file, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)

        assert_text "We're analysing your code for suggestions"

        click_on "Tests"
        assert_text "We're testing your code to check it works"
      end
    end

    test "user views iteration with no automated feedback" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user
      submission = create :submission, solution: solution,
                                       tests_status: :passed,
                                       representation_status: :generated,
                                       analysis_status: :completed
      create :iteration, solution: solution, submission: submission
      create :submission_file, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)

        assert_text "No auto suggestions? Try human mentoring."
      end
    end

    test "user views iteration with failed tests" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user
      submission = create :submission, solution: solution, tests_status: :failed
      create :iteration, solution: solution, submission: submission
      create :submission_file, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)

        assert_text "No auto suggestions? Try human mentoring."
      end
    end

    test "user views representer feedback" do
      user = create :user
      author = create :user, name: "Feedback author"
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user
      submission = create :submission, solution: solution,
                                       tests_status: :passed,
                                       representation_status: :generated,
                                       analysis_status: :completed
      create :exercise_representation,
        exercise: exercise,
        source_submission: submission,
        feedback_author: author,
        feedback_markdown: "Good job",
        feedback_type: :essential,
        ast_digest: "AST"
      create :submission_representation,
        submission: submission,
        ast_digest: "AST"
      create :iteration, solution: solution, submission: submission
      create :submission_file, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_path(track, exercise)

        assert_text "Feedback author gave this feedback on a solution very similar to yours"
        assert_text "Good job"
      end
    end

    test "user views analyzer feedback" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user
      submission = create :submission, solution: solution,
                                       tests_status: :passed,
                                       representation_status: :generated,
                                       analysis_status: :completed
      create :iteration, solution: solution, submission: submission
      create :submission_file, submission: submission
      create :submission_analysis, submission: submission, data: {
        comments: [
          { type: "essential", comment: "ruby.two-fer.splat_args" }
        ]
      }

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)

        assert_text "Our Ruby Analyzer has some comments on your solution"
        assert_text "Define an explicit"
      end
    end

    test "user views test run" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user
      submission = create :submission, solution: solution,
                                       tests_status: :passed,
                                       representation_status: :generated,
                                       analysis_status: :completed
      create :iteration, solution: solution, submission: submission
      create :submission_test_run,
        submission: submission,
        status: "fail",
        ops_status: 200,
        raw_results: {
          version: 3,
          tests: [{ name: :test_no_name_given, status: :fail, task_id: 1 }]
        }

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)
        click_on "Tests"

        assert_text "1 test failed"
      end
    end
  end
end
