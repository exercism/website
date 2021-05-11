require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module CommunitySolutions
    class UserStarsASolutionTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user sees correct stars and status" do
        author = create :user
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, published_at: 2.days.ago, exercise: exercise, user: author
        submission = create :submission, solution: solution
        create :iteration, idx: 1, solution: solution, submission: submission
        3.times { create :solution_star, solution: solution }

        use_capybara_host do
          sign_in!
          visit track_exercise_community_solution_path(exercise.track, exercise, author.handle)

          within(".star-button") { assert_text "3" }
        end
      end

      test "user stars a solution" do
        author = create :user
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, published_at: 2.days.ago, exercise: exercise, user: author
        submission = create :submission, solution: solution
        create :iteration, idx: 1, solution: solution, submission: submission

        use_capybara_host do
          sign_in!
          visit track_exercise_community_solution_path(exercise.track, exercise, author.handle)
          find(".star-button").click

          within(".star-button") { assert_text "1" }
        end
      end

      test "user unstars a solution" do
        user = create :user
        author = create :user
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, published_at: 2.days.ago, exercise: exercise, user: author
        submission = create :submission, solution: solution
        create :iteration, published: true, idx: 1, solution: solution, submission: submission
        create :solution_star, solution: solution, user: user

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_community_solution_path(exercise.track, exercise, author.handle)
          find(".star-button").click

          within(".star-button") { assert_text "0" }
        end
      end
    end
  end
end
