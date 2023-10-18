require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module Exercise
      class ViewsExerciseMentoringTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "no mentoring" do
          user = create :user
          track = create :track
          create(:user_track, user:, track:)
          exercise = create(:concept_exercise, track:)
          solution = create(:concept_solution, exercise:, user:)
          submission = create(:submission, tests_status: :queued, solution:)
          create(:iteration, solution:, submission:)
          create(:submission_file, submission:)

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussions_path(track, exercise)

            assert_text "You have no past code review sessions"
            click_on "Submit for code review"
            assert_text "Submit mentoring request"
          end
        end

        test "requested mentoring" do
          user = create :user
          track = create :track
          create(:user_track, user:, track:)
          exercise = create(:concept_exercise, track:)
          solution = create(:concept_solution, exercise:, user:)
          submission = create(:submission, tests_status: :queued, solution:)
          create(:iteration, solution:, submission:)
          create(:submission_file, submission:)

          create :mentor_request, solution:, student: user

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussions_path(track, exercise)

            assert_text "requested mentoring"
            assert_text "Waiting on a mentor…"
          end
        end

        test "in progress mentoring discussion" do
          user = create :user
          mentor = create :user, handle: 'juanita'
          track = create :track
          create(:user_track, user:, track:)
          exercise = create(:concept_exercise, track:)
          solution = create(:concept_solution, exercise:, user:)
          submission = create(:submission, tests_status: :queued, solution:)
          create(:iteration, solution:, submission:)
          create(:submission_file, submission:)

          create(:mentor_discussion, :awaiting_student, solution:, student: user, mentor:)

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussions_path(track, exercise)

            within(".mentoring-in-progress") { assert_text "juanita" }
          end
        end

        test "past mentoring discussions" do
          user = create :user
          mentor_1 = create :user, handle: 'juanita'
          mentor_2 = create :user, handle: 'aziz'
          mentor_3 = create :user, handle: 'yamikani'
          track = create :track
          create(:user_track, user:, track:)
          exercise = create(:concept_exercise, track:)
          solution = create(:concept_solution, exercise:, user:)
          submission = create(:submission, tests_status: :queued, solution:)
          create(:iteration, solution:, submission:)
          create(:submission_file, submission:)

          create :mentor_discussion, :student_finished, solution:, student: user, mentor: mentor_1
          create :mentor_discussion, :student_finished, solution:, student: user, mentor: mentor_2

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussions_path(track, exercise)

            within(".previous-discussions") do
              assert_text "juanita"
              assert_text "aziz"
              refute_text "yamikani"
            end

            # Create discussion finished by mentor
            discussion = create :mentor_discussion, :mentor_finished, solution:, student: user, mentor: mentor_3
            solution.mentoring_in_progress!

            # Reload page
            visit track_exercise_mentor_discussions_path(track, exercise)

            within(".previous-discussions") do
              assert_text "juanita"
              assert_text "aziz"
              refute_text "yamikani"
            end

            within(".mentoring-in-progress") { assert_text "yamikani" }

            Mentor::Discussion::FinishByStudent.(discussion, 5)

            # Reload page
            visit track_exercise_mentor_discussions_path(track, exercise)

            within(".previous-discussions") do
              assert_text "juanita"
              assert_text "aziz"
              assert_text "yamikani"
            end
          end
        end
      end
    end
  end
end
