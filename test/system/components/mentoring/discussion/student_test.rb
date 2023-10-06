require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Components
  module Mentoring
    module Discussion
      class StudentTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "shows student info" do
          mentor = create :user
          student = create :user, name: "Apprentice", handle: "student", reputation: 1500, pronouns: "They/them/Their"
          ruby = create :track, title: "Ruby"
          running = create :concept_exercise, title: "Running", track: ruby
          solution = create :concept_solution, exercise: running, user: student
          discussion = create(:mentor_discussion, solution:, mentor:)
          submission = create(:submission, solution:)
          create(:iteration, idx: 1, solution:, submission:)

          use_capybara_host do
            sign_in!(mentor)
            visit mentoring_discussion_path(discussion)
          end

          within(".student-info") do
            assert_text student.name
            assert_text student.handle.to_s
            assert_text student.formatted_reputation
            assert_text "They / them / Their"
            assert_css "img[src='#{student.avatar_url}']"\
              "[alt=\"Uploaded avatar of student\"]"
            assert_button "Add to favorites"
          end
        end

        test "mentor receives latest iteration via channel clicks on new then new label disappears" do
          mentor = create :user
          student = create :user
          create :track
          running = create :concept_exercise
          solution = create :concept_solution, exercise: running, user: student
          discussion = create(:mentor_discussion, solution:, mentor:)
          submission = create(:submission, solution:)
          create(:iteration, idx: 1, solution:, submission:)

          use_capybara_host do
            sign_in!(mentor)
            visit mentoring_discussion_path(discussion)
            sleep 1
            create(:iteration, idx: 2, solution:)
            SolutionWithLatestIterationChannel.broadcast!(solution)
            wait_for_websockets
            assert_css ".c-iterations-footer"
            within(".c-iterations-footer") do
              assert_text "NEW"
              assert_selector ".new", count: 1

              click_on "2"
              refute_text "NEW"
            end
          end
        end

        test "views track objectives" do
          mentor = create :user
          student = create :user, handle: "student"
          ruby = create :track
          create :user_track, user: student, track: ruby, objectives: "I want to learn Ruby"
          exercise = create :concept_exercise, track: ruby
          solution = create :concept_solution, exercise:, user: student
          discussion = create(:mentor_discussion, solution:, mentor:)
          submission = create(:submission, solution:)
          create(:iteration, idx: 1, solution:, submission:)

          use_capybara_host do
            sign_in!(mentor)
            visit mentoring_discussion_path(discussion)
            find("summary", text: "Explore student's track goal(s)").click

            assert_text "I want to learn Ruby"
          end
        end

        test "remove student from favorites" do
          mentor = create :user
          student = create :user
          ruby = create :track, title: "Ruby"
          running = create :concept_exercise, title: "Running", track: ruby
          solution = create :concept_solution, exercise: running, user: student
          discussion = create(:mentor_discussion, solution:, mentor:)
          submission = create(:submission, solution:)
          create(:iteration, idx: 1, solution:, submission:)
          create :mentor_student_relationship, mentor:, student:, favorited: true

          use_capybara_host do
            sign_in!(mentor)
            visit mentoring_discussion_path(discussion)

            find_button("Favorited").hover
            click_on "Unfavorite?"

            assert_button "Add to favorites"
          end
        end

        test "add student to favorites" do
          mentor = create :user
          student = create :user
          ruby = create :track, title: "Ruby"
          running = create :concept_exercise, title: "Running", track: ruby
          solution = create :concept_solution, exercise: running, user: student
          discussion = create(:mentor_discussion, solution:, mentor:)
          create(:iteration, idx: 1, solution:)

          use_capybara_host do
            sign_in!(mentor)
            visit mentoring_discussion_path(discussion)

            click_on "Add to favorites"

            assert_text "Favorited"
          end
        end
      end
    end
  end
end
