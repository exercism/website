require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserViewsCommunitySolutionsTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows community solutions for an exercise" do
      user = create :user
      author = create :user, handle: "author"
      ruby = create :track, title: "Ruby"
      exercise = create :concept_exercise, track: ruby, title: "Strings"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_community_solutions_path(exercise.track, exercise)
      end

      assert_text "author's solution"
      assert_text "to Strings in Ruby"
    end

    test "searches community solutions" do
      user = create :user
      author = create :user, handle: "author1"
      other_author = create :user, handle: "author2"
      ruby = create :track, title: "Ruby"
      exercise = create :concept_exercise, track: ruby, title: "Strings"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission
      other_solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: other_author
      other_submission = create :submission, solution: other_solution
      create :iteration, solution: other_solution, submission: other_submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_community_solutions_path(exercise.track, exercise)
        fill_in "Search by user", with: "author2"
      end

      assert_text "author2's solution"
      assert_no_text "author1's solution"
    end

    test "paginates community solutions" do
      Solution::SearchCommunitySolutions.stubs(:default_per).returns(1)
      user = create :user
      author = create :user, handle: "author1"
      other_author = create :user, handle: "author2"
      ruby = create :track, title: "Ruby"
      exercise = create :concept_exercise, track: ruby, title: "Strings"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission
      other_solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: other_author
      other_submission = create :submission, solution: other_solution
      create :iteration, solution: other_solution, submission: other_submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_community_solutions_path(exercise.track, exercise)
        click_on "2"
      end

      assert_text "author2's solution"
      assert_no_text "author1's solution"
    end
  end
end
