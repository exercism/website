require "application_system_test_case"

module Flows
  class ViewIterationsTest < ApplicationSystemTestCase
    test "user views iterations" do
      Submission::File.any_instance.stubs(:content)
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user
      submission = create :submission, tests_status: :queued, solution: solution, submitted_via: :cli
      iteration = create :iteration, idx: 2, solution: solution, submission: submission
      create :submission_file, submission: submission

      sign_in!(user)
      visit track_exercise_iterations_url(track, exercise)

      assert_text "Iteration 2"
      assert_text "Queued"

      submission.update!(tests_status: :pass)
      IterationsChannel.broadcast!(iteration)
      assert_text "Passed"
    end
  end
end
