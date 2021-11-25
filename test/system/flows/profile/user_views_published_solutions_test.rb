require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  class UserViewsPublishedSolutionsTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows published solutions" do
      # TODO: Change this stub
      User::Profile.any_instance.expects(solutions_tab?: true).at_least_once
      author = create :user, handle: "author"
      create :user_profile, user: author
      ruby = create :track, title: "Ruby"
      exercise = create :concept_exercise, track: ruby, title: "Strings"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission

      wait_for_opensearch_to_be_synced

      use_capybara_host do
        sign_in!(author)
        visit solutions_profile_path(author.handle)
      end

      assert_text "Strings"
    end

    test "shows published solutions for a logged out user" do
      # TODO: Change this stub
      User::Profile.any_instance.expects(solutions_tab?: true).at_least_once
      author = create :user, handle: "author"
      create :user_profile, user: author
      ruby = create :track, title: "Ruby"
      exercise = create :concept_exercise, track: ruby, slug: "strings", title: "Strings"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission
      exercise = create :concept_exercise, track: ruby, slug: "Running", title: "Running"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission

      wait_for_opensearch_to_be_synced

      use_capybara_host do
        visit solutions_profile_path(author.handle)
        fill_in "Filter by exercise", with: "Strings"
      end

      assert_text "Strings"
      assert_no_text "Running"
    end

    test "searches published solutions" do
      # TODO: Change this stub
      User::Profile.any_instance.expects(solutions_tab?: true).at_least_once
      author = create :user, handle: "author"
      create :user_profile, user: author
      ruby = create :track, title: "Ruby"
      exercise = create :concept_exercise, track: ruby, slug: "strings", title: "Strings"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission
      exercise = create :concept_exercise, track: ruby, slug: "Running", title: "Running"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission

      wait_for_opensearch_to_be_synced

      use_capybara_host do
        sign_in!(author)
        visit solutions_profile_path(author.handle)
        fill_in "Filter by exercise", with: "Strings"
      end

      assert_text "Strings"
      assert_no_text "Running"
    end

    test "sorts published solutions" do
      # TODO: Change this stub
      User::Profile.any_instance.expects(solutions_tab?: true).at_least_once
      Solution::SearchUserSolutions.stubs(:default_per).returns(1)
      author = create :user, handle: "author"
      create :user_profile, user: author
      ruby = create :track, title: "Ruby"
      exercise = create :concept_exercise, track: ruby, title: "Strings"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission
      exercise = create :concept_exercise, track: ruby, slug: "Running", title: "Running"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission

      wait_for_opensearch_to_be_synced

      use_capybara_host do
        sign_in!(author)
        visit solutions_profile_path(author.handle)
        click_on "Sort by Newest First"
        find("label", text: "Sort by Oldest First").click
      end

      assert_text "Strings"
      assert_no_text "Running"
    end

    test "filters published solutions by track" do
      # TODO: Change this stub
      User::Profile.any_instance.expects(solutions_tab?: true).at_least_once
      author = create :user, handle: "author"
      create :user_profile, user: author
      ruby = create :track, title: "Ruby", slug: "ruby"
      csharp = create :track, title: "C#", slug: "csharp"
      create :user_track, track: csharp, user: author
      create :user_track, track: ruby, user: author
      exercise = create :concept_exercise, track: ruby, title: "Strings"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission
      exercise = create :concept_exercise, track: csharp, slug: "Running", title: "Running"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission

      wait_for_opensearch_to_be_synced

      use_capybara_host do
        sign_in!(author)
        visit solutions_profile_path(author.handle)
        click_on "All Tracks"
        find("label", text: "Ruby").click
      end

      assert_text "Strings"
      assert_no_text "Running"
    end
  end
end
