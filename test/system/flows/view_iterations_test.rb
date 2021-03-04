require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class ViewIterationsTest < ApplicationSystemTestCase
    include CapybaraHelpers

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

      sign_in!(user)
      visit track_exercise_iterations_url(track, exercise)

      assert_text "We're analysing your code for suggestions"
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

      sign_in!(user)
      visit track_exercise_iterations_url(track, exercise)

      assert_text "No auto suggestions? Try human mentoring."
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
        feedback_author: author,
        feedback_markdown: "Good job",
        feedback_type: :essential,
        ast_digest: "AST"
      create :submission_representation,
        submission: submission,
        ast_digest: "AST"
      create :iteration, solution: solution, submission: submission
      create :submission_file, submission: submission

      sign_in!(user)
      visit track_exercise_iterations_url(track, exercise)

      assert_text "Feedback author gave this feedback on a solution very similar to yours"
      assert_text "Good job"
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

      sign_in!(user)
      visit track_exercise_iterations_url(track, exercise)

      assert_text "Our Ruby Analyzer has some comments on your solution"
      assert_text "Define an explicit"
    end
  end
end
