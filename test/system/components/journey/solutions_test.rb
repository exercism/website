require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Journey
    class SolutionsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows solutions" do
        user = create :user
        track = create :track, title: "Ruby"
        exercise = create :concept_exercise, title: "Lasagna", icon_name: 'lasagna', track:, slug: :lasagna
        solution = create :concept_solution, :completed, exercise:, completed_at: Time.current, user:,
          num_views: 1270, num_comments: 10, num_stars: 12, num_loc: 18
        create(:submission, solution:)
        travel_to(Time.current - 2.days) do
          3.times { create :iteration, solution: }
        end

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path

          assert_text "Ruby"
          assert_text "Lasagna"
          assert_text "Completed"
          assert_text "1270 views"
          assert_text "10"
          assert_text "2"
          assert_text "3 iterations"
          assert_text "18"
          assert_text "Last submitted 2 days ago"
          assert_link "Lasagna", href: Exercism::Routes.private_solution_url(solution)
          assert_css "img[src='#{track.icon_url}']"
          assert_css "img[src='#{exercise.icon_url}']"
        end
      end

      test "hides last submitted for non-submitted solution" do
        user = create :user
        solution = create(:concept_solution, user:)

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path

          assert_text solution.exercise.title
          refute_text "Last submitted"
        end
      end

      test "paginates solutions" do
        Solution::SearchUserSolutions.stubs(:default_per).returns(1)
        user = create :user
        exercise = create :concept_exercise, title: "Bob"
        exercise_2 = create :concept_exercise, title: "Lasagna"
        create :concept_solution, exercise:, user:, published_at: 2.days.ago
        create :concept_solution, exercise: exercise_2, user:, published_at: 1.day.ago

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path

          assert_text "Showing 2 solutions"
          assert_text "Lasagna"
          assert_no_text "Bob"

          click_on "2"

          assert_text "Bob"
          assert_no_text "Lasagna"
        end
      end

      test "searches solutions" do
        Solution::SearchUserSolutions.stubs(:default_per).returns(1)
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        create(:concept_solution, exercise:, user:)
        create(:concept_solution, exercise: exercise_2, user:)

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          fill_in "Search by exercise or track name", with: "Bob"
        end

        assert_text "Bob"
        assert_no_text "Lasagna"
      end

      test "filters by exercise status" do
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        create :concept_solution, exercise:, user:, status: :published
        create :concept_solution,
          exercise: exercise_2,
          user:,
          completed_at: Time.current,
          published_at: Time.current,
          mentoring_status: :requested,
          status: :started

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          click_on "Filter by"
          click_on "Exercise status"
          find("label", text: "Started").click
          click_on "Apply filters"
        end

        assert_text "Bob"
        assert_no_text "Lasagna"
      end

      test "filters by mentoring status" do
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        create(:concept_solution, exercise:, user:)
        create :concept_solution,
          exercise: exercise_2,
          user:,
          completed_at: Time.current,
          published_at: Time.current,
          mentoring_status: :requested

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          click_on "Filter by"
          click_on "Mentoring status"
          find("label", text: "Requested").click
          click_on "Apply filters"
        end

        assert_text "Bob"
        assert_no_text "Lasagna"
      end

      test "filters by mentoring completed status" do
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        create(:concept_solution, exercise:, user:)
        create :concept_solution,
          exercise: exercise_2,
          user:,
          completed_at: Time.current,
          published_at: Time.current,
          mentoring_status: :finished

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          click_on "Filter by"
          click_on "Mentoring status"
          find("label", text: "Mentoring Completed").click
          click_on "Apply filters"
        end

        assert_text "Bob"
        assert_no_text "Lasagna"
      end

      test "filters by sync status" do
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        create :concept_solution, exercise:, user:, git_important_files_hash: exercise.git_important_files_hash
        create :concept_solution,
          exercise: exercise_2,
          user:,
          completed_at: Time.current,
          published_at: Time.current,
          git_important_files_hash: 'other-hash'

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          click_on "Filter by"
          click_on "Sync status"
          find("label", text: "Up-to-date").click
          click_on "Apply filters"
        end

        assert_text "Lasagna"
        assert_no_text "Bob"
      end

      test "filters by tests status" do
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        solution_1 = create :concept_solution, exercise:, user:, published_at: Time.current
        solution_2 = create :concept_solution,
          exercise: exercise_2,
          user:,
          completed_at: Time.current,
          published_at: Time.current
        submission_1 = create :submission, solution: solution_1
        submission_2 = create :submission, solution: solution_2
        solution_1.update!(published_iteration: create(:iteration, solution: solution_1, submission: submission_1))
        solution_2.update!(published_iteration: create(:iteration, solution: solution_2, submission: submission_2))

        perform_enqueued_jobs_until_empty
        submission_1.reload.update_column(:tests_status, :failed)
        submission_2.reload.update_column(:tests_status, :passed)

        Solution::SyncToSearchIndex.(solution_1)
        Solution::SyncToSearchIndex.(solution_2)
        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          click_on "Filter by"
          click_on "Tests status"
          find("label", text: "Passed").click
          click_on "Apply filters"
        end

        assert_text "Bob"
        assert_no_text "Lasagna"
      end

      test "filters by head tests status" do
        Solution::QueueHeadTestRun.stubs(:defer)

        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        solution_1 = create :concept_solution,
          exercise:,
          user:,
          published_at: Time.current,
          published_iteration_head_tests_status: :passed
        solution_2 = create :concept_solution,
          exercise: exercise_2,
          user:,
          completed_at: Time.current,
          published_at: Time.current,
          published_iteration_head_tests_status: :errored
        submission_1 = create :submission, solution: solution_1, tests_status: :failed
        submission_2 = create :submission, solution: solution_2, tests_status: :passed
        solution_1.update!(published_iteration: create(:iteration, solution: solution_1, submission: submission_1))
        solution_2.update!(published_iteration: create(:iteration, solution: solution_2, submission: submission_2))

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          click_on "Filter by"
          click_on "Latest Tests status"
          find("label", text: "Passed").click
          click_on "Apply filters"
        end

        assert_text "Lasagna"
        assert_no_text "Bob"
      end

      test "user resets filters" do
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        create(:concept_solution, exercise:, user:)
        create :concept_solution,
          exercise: exercise_2,
          user:,
          completed_at: Time.current,
          published_at: Time.current,
          mentoring_status: :requested

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          click_on "Filter by"
          click_on "Mentoring status"
          find("label", text: "Requested").click
          click_on "Apply filters"
          click_on "Reset filters"
        end

        assert_text "Bob"
        assert_text "Lasagna"
      end

      test "sorts solutions" do
        Solution::SearchUserSolutions.stubs(:default_per).returns(1)
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        create :concept_solution, exercise:, user:, created_at: 2.days.ago
        create :concept_solution, exercise: exercise_2, user:, created_at: 3.days.ago

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          click_on "Newest First"
          find("label", text: "Oldest First").click
        end

        assert_no_text "Bob"
        assert_text "Lasagna"
      end

      private
      def assert_icon(name)
        assert_css "use[*|href=\"##{name}\"]", visible: false
      end
    end
  end
end
