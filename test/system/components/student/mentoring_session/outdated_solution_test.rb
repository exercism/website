require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Components
  module Student
    module MentoringSession
      class OutdatedSolutionTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "student sees outdated solution notice" do
          mentor = create :user
          student = create :user
          track = create :track
          exercise = create :concept_exercise, track: track
          solution = create :concept_solution, user: student, exercise: exercise, git_important_files_hash: "outdated"
          request = create :mentor_request, solution: solution
          discussion = create :mentor_discussion, solution: solution, mentor: mentor, request: request
          submission = create :submission, solution: solution
          create :iteration, solution: solution, submission: submission

          use_capybara_host do
            sign_in!(student)
            visit track_exercise_mentor_discussion_path(track, exercise, discussion)
            find(".--status", text: "Outdated").hover

            assert_text "This exercise has been updated since this iteration was submitted."
          end
        end
      end
    end
  end
end
