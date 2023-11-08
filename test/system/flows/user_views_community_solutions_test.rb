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
      solution = create :concept_solution, exercise:, published_at: 2.days.ago, user: author,
        published_iteration_head_tests_status: :passed
      submission = create(:submission, solution:, tests_status: :passed)
      exercise_representation = create(:exercise_representation, source_submission: submission)
      solution.update!(published_exercise_representation: exercise_representation)
      create :submission_representation, submission:, ast: exercise_representation.ast
      create(:iteration, solution:, submission:)

      perform_enqueued_jobs do
        Exercise::Representation::Recache.(exercise_representation, force: true)
      end

      wait_for_opensearch_to_be_synced

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_solutions_path(ruby, exercise)
      end

      assert_text "author's solution"
      assert_text "to Strings in Ruby"
    end

    test "searches community solutions" do
      user = create :user
      author = create :user, handle: "author1"
      other_author = create :user, handle: "author2"
      ruby = create :track, title: "Ruby"
      exercise = create :practice_exercise, track: ruby
      exercise_representation_1 = create(:exercise_representation, exercise:)
      exercise_representation_2 = create(:exercise_representation, exercise:)

      solution_1 = create :concept_solution, exercise:, published_at: 2.days.ago, user: author,
        git_important_files_hash: exercise.git_important_files_hash,
        published_iteration_head_tests_status: :passed,
        published_exercise_representation: exercise_representation_1
      submission = create :submission, solution: solution_1, tests_status: :passed
      create :submission_representation, submission:, ast: exercise_representation_1.ast
      create :submission_file, submission:, filename: "main.rb", content: "def my_main; end"
      create(:iteration, solution: solution_1, submission:)

      solution_2 = create :concept_solution, exercise:, published_at: 2.days.ago, user: other_author,
        git_important_files_hash: exercise.git_important_files_hash,
        published_iteration_head_tests_status: :passed,
        published_exercise_representation: exercise_representation_2
      submission = create :submission, solution: solution_2, tests_status: :passed
      create :submission_representation, submission:, ast: exercise_representation_2.ast
      create :submission_file, submission:, filename: "main.rb", content: "def your_main; end"
      create(:iteration, solution: solution_2, submission:)

      perform_enqueued_jobs do
        Exercise::Representation::Recache.(exercise_representation_1)
        Exercise::Representation::Recache.(exercise_representation_2)
      end

      wait_for_opensearch_to_be_synced

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_solutions_path(exercise.track, exercise)
        fill_in "Search by code (min 3 chars)", with: "your_main"
      end

      assert_text "author2's solution"
      assert_no_text "author1's solution"
    end

    test "paginates community solutions" do
      Solution::SearchViaRepresentations.stubs(:default_per).returns(1)
      user = create :user
      author = create :user, handle: "author1"
      other_author = create :user, handle: "author2"
      ruby = create :track, title: "Ruby"
      exercise = create :practice_exercise, track: ruby
      exercise_representation_1 = create(:exercise_representation, exercise:)
      exercise_representation_2 = create(:exercise_representation, exercise:)

      solution_1 = create :concept_solution, exercise:, published_at: 2.days.ago, user: author,
        git_important_files_hash: exercise.git_important_files_hash,
        published_iteration_head_tests_status: :passed,
        published_exercise_representation: exercise_representation_1
      submission = create :submission, solution: solution_1, tests_status: :passed
      create :submission_representation, submission:, ast: exercise_representation_1.ast
      create :submission_file, submission:, filename: "main.rb", content: "def my_main; end"
      create(:iteration, solution: solution_1, submission:)

      solution_2 = create :concept_solution, exercise:, published_at: 2.days.ago, user: other_author,
        git_important_files_hash: exercise.git_important_files_hash,
        published_iteration_head_tests_status: :passed,
        published_exercise_representation: exercise_representation_2
      submission = create :submission, solution: solution_2, tests_status: :passed
      create :submission_representation, submission:, ast: exercise_representation_2.ast
      create :submission_file, submission:, filename: "main.rb", content: "def your_main; end"
      create(:iteration, solution: solution_2, submission:)

      perform_enqueued_jobs do
        Exercise::Representation::Recache.(exercise_representation_1)
        Exercise::Representation::Recache.(exercise_representation_2)
      end

      wait_for_opensearch_to_be_synced

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_solutions_path(exercise.track, exercise)

        assert_text "author1's solution"
        assert_no_text "author2's solution"

        click_on "2"

        assert_text "author2's solution"
        assert_no_text "author1's solution"
      end
    end

    test "views iterations per community solution" do
      user = create :user, handle: "handle"
      ruby = create :track, slug: "ruby"
      exercise = create :concept_exercise, track: ruby
      solution = create(:concept_solution, :published, published_at: 2.days.ago, exercise:, user:)
      submission_1 = create(:submission, solution:)
      create :submission_file,
        submission: submission_1,
        content: "class Bob\nend",
        filename: "bob.rb"
      submission_2 = create(:submission, solution:)
      create :submission_file,
        submission: submission_2,
        content: "class Lasagna\nend",
        filename: "bob.rb"
      create :iteration, idx: 1, solution:, submission: submission_1
      create :iteration, idx: 2, solution:, submission: submission_2

      use_capybara_host do
        sign_in!
        visit track_exercise_solution_path(exercise.track, exercise, user.handle)
        assert_text "class Lasagna", wait: 2

        within("footer .iterations") { click_on "1" }
        refute_text "class Lasagna", wait: 2
        assert_text "class Bob", wait: 2
      end
    end

    test "viewing other solutions on community solution" do
      user = create :user, handle: "Jane"
      other_user_1 = create :user, handle: "John"
      other_user_2 = create :user, handle: "Niesha"
      other_user_3 = create :user, handle: "Iko"
      ruby = create :track, slug: "ruby"
      exercise = create :concept_exercise, track: ruby
      solution = create(:concept_solution, :published, published_at: 2.days.ago, exercise:, user:)
      create :concept_solution, :published, published_at: 3.days.ago, exercise:, user: other_user_1,
        published_iteration_head_tests_status: :passed
      create :concept_solution, :published, published_at: 4.days.ago, exercise:, user: other_user_2,
        published_iteration_head_tests_status: :failed
      create :concept_solution, :published, published_at: 5.days.ago, exercise:, user: other_user_3,
        published_iteration_head_tests_status: :queued

      submission_1 = create(:submission, solution:)
      create :submission_file,
        submission: submission_1,
        content: "class Bob\nend",
        filename: "bob.rb"
      submission_2 = create(:submission, solution:)
      create :submission_file,
        submission: submission_2,
        content: "class Lasagna\nend",
        filename: "bob.rb"
      create :iteration, idx: 1, solution:, submission: submission_1
      create :iteration, idx: 2, solution:, submission: submission_2

      use_capybara_host do
        sign_in!
        visit track_exercise_solution_path(exercise.track, exercise, user.handle)

        within(".other-solutions") do
          # Own solution is not shown
          refute_text "Jane's solution", wait: 2

          # Other user's published solution with published iteration head tests status is :passed are shown
          assert_text "John's solution", wait: 2

          # Other user's published solution with published iteration head tests status is :queued are shown
          assert_text "Iko's solution", wait: 2

          # Other user's published solution with published iteration head tests status is :failed is not shown
          refute_text "Niesha's solution", wait: 2
        end
      end
    end
  end
end
