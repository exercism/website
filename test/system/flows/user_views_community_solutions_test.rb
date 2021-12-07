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
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author,
                                           published_iteration_head_tests_status: :passed
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission

      wait_for_opensearch_to_be_synced

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_solutions_path(exercise.track, exercise)
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
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author,
                                           published_iteration_head_tests_status: :passed
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission
      other_solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: other_author,
                                                 published_iteration_head_tests_status: :passed
      other_submission = create :submission, solution: other_solution
      create :iteration, solution: other_solution, submission: other_submission

      wait_for_opensearch_to_be_synced

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_solutions_path(exercise.track, exercise)
        fill_in "Search by user", with: "author2"
      end

      assert_text "author2's solution"
      assert_no_text "author1's solution"
    end

    test "filter community solutions" do
      user = create :user
      author = create :user, handle: "author1"
      other_author = create :user, handle: "author2"
      another_author = create :user, handle: "author3"
      ruby = create :track, title: "Ruby"
      exercise = create :concept_exercise, track: ruby, title: "Strings"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author, num_stars: 11,
                                           git_important_files_hash: exercise.git_important_files_hash,
                                           published_iteration_head_tests_status: :queued
      submission = create :submission, solution: solution, tests_status: :passed
      create :iteration, solution: solution, submission: submission
      other_solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: other_author, num_stars: 22,
                                                 git_important_files_hash: exercise.git_important_files_hash,
                                                 published_iteration_head_tests_status: :failed
      other_submission = create :submission, solution: other_solution, tests_status: :failed
      create :iteration, solution: other_solution, submission: other_submission
      another_solution = create :concept_solution, exercise: exercise, published_at: 4.days.ago, user: another_author, num_stars: 33,
                                                   git_important_files_hash: 'another-hash',
                                                   published_iteration_head_tests_status: :passed
      another_submission = create :submission, solution: another_solution, tests_status: :failed
      create :iteration, solution: another_solution, submission: another_submission

      wait_for_opensearch_to_be_synced

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_solutions_path(exercise.track, exercise)
      end

      # Default: head tests passed filter is one
      assert_text "author1's solution"
      assert_no_text "author2's solution"
      assert_text "author3's solution"

      # Disable head tests passed filter
      use_capybara_host do
        find("img[alt='Only show solution that pass the tests of the latest version of this exercise']").click
      end

      assert_text "author1's solution"
      assert_text "author2's solution"
      assert_text "author3's solution"

      # Enable up-to-date filter
      use_capybara_host do
        find("img[alt='Only show solutions that are up-to-date with the latest version of this exercise']").click
      end

      sleep(0.1)

      assert_text "author1's solution"
      assert_text "author2's solution"
      assert_no_text "author3's solution"

      # Enable tests passing filter
      use_capybara_host do
        find(".c-search-bar .--passed").click
      end

      sleep(0.1)

      assert_text "author1's solution"
      assert_no_text "author2's solution"
      assert_no_text "author3's solution"
    end

    test "paginates community solutions" do
      Solution::SearchCommunitySolutions.stubs(:default_per).returns(1)
      user = create :user
      author = create :user, handle: "author1"
      other_author = create :user, handle: "author2"
      ruby = create :track, title: "Ruby"
      exercise = create :concept_exercise, track: ruby, title: "Strings"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author, num_stars: 11,
                                           published_iteration_head_tests_status: :passed
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission
      other_solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: other_author, num_stars: 22,
                                                 published_iteration_head_tests_status: :passed
      other_submission = create :submission, solution: other_solution
      create :iteration, solution: other_solution, submission: other_submission

      wait_for_opensearch_to_be_synced

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_solutions_path(exercise.track, exercise)

        assert_text "author2's solution"
        assert_no_text "author1's solution"

        click_on "2"

        assert_text "author1's solution"
        assert_no_text "author2's solution"
      end
    end

    test "views iterations per community solution" do
      user = create :user, handle: "handle"
      ruby = create :track, slug: "ruby"
      exercise = create :concept_exercise, track: ruby
      solution = create :concept_solution, :published, published_at: 2.days.ago, exercise: exercise, user: user
      submission_1 = create :submission, solution: solution
      create :submission_file,
        submission: submission_1,
        content: "class Bob\nend",
        filename: "bob.rb"
      submission_2 = create :submission, solution: solution
      create :submission_file,
        submission: submission_2,
        content: "class Lasagna\nend",
        filename: "bob.rb"
      create :iteration, idx: 1, solution: solution, submission: submission_1
      create :iteration, idx: 2, solution: solution, submission: submission_2

      use_capybara_host do
        sign_in!
        visit track_exercise_solution_path(exercise.track, exercise, user.handle)
        assert_text "class Lasagna", wait: 2

        within("footer .iterations") { click_on "1" }
        refute_text "class Lasagna", wait: 2
        assert_text "class Bob", wait: 2
      end
    end
  end
end
