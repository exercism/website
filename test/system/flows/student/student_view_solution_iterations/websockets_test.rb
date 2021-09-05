require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module StudentViewsSolutionIterations
      class WebsocketsTest < ApplicationSystemTestCase
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

            assert_text "Processing"

            submission_analysis_finished!(submission)

            assert_text "Our Ruby Analyzer has some comments on your solution"
          end
        end

        private
        def submission_analysis_finished!(submission)
          create :submission_analysis, submission: submission, data: {
            comments: [
              { type: "essential", comment: "ruby.two-fer.splat_args" }
            ]
          }
          submission.update!(tests_status: :passed)
          SolutionChannel.broadcast!(submission.solution)
        end
      end
    end
  end
end
