require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Journey
    class SolutionsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows solutions" do
        user = create :user
        track = create :track, title: "Ruby"
        exercise = create :concept_exercise, title: "Lasagna", icon_name: 'lasagna', track: track, slug: :lasagna
        solution = create :concept_solution, :completed, exercise: exercise, completed_at: Time.current, user: user,
                                                         num_views: 1270, num_comments: 10, num_stars: 12, num_loc: 18
        create :submission, solution: solution
        travel_to(Time.current - 2.days) do
          3.times { create :iteration, solution: solution }
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
        solution = create :concept_solution, user: user

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
        create :concept_solution, exercise: exercise, user: user, published_at: 2.days.ago
        create :concept_solution, exercise: exercise_2, user: user, published_at: 1.day.ago

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
        create :concept_solution, exercise: exercise, user: user
        create :concept_solution, exercise: exercise_2, user: user

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          fill_in "Search by exercise name", with: "Bob"
        end

        assert_text "Bob"
        assert_no_text "Lasagna"
      end

      test "filters by exercise status" do
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        create :concept_solution, exercise: exercise, user: user, status: :published
        create :concept_solution,
          exercise: exercise_2,
          user: user,
          completed_at: Time.current,
          published_at: Time.current,
          mentoring_status: :requested,
          status: :started

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          click_on "Exercise status"
          find("label", text: "Started").click
        end

        assert_text "Bob"
        assert_no_text "Lasagna"
      end

      test "filters by mentoring status" do
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        create :concept_solution, exercise: exercise, user: user
        create :concept_solution,
          exercise: exercise_2,
          user: user,
          completed_at: Time.current,
          published_at: Time.current,
          mentoring_status: :requested

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          click_on "Mentoring status"
          find("label", text: "Requested").click
        end

        assert_text "Bob"
        assert_no_text "Lasagna"
      end

      test "filters by mentoring completed status" do
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        create :concept_solution, exercise: exercise, user: user
        create :concept_solution,
          exercise: exercise_2,
          user: user,
          completed_at: Time.current,
          published_at: Time.current,
          mentoring_status: :finished

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          click_on "Mentoring status"
          find("label", text: "Mentoring Completed").click
        end

        assert_text "Bob"
        assert_no_text "Lasagna"
      end

      test "user resets filters" do
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        create :concept_solution, exercise: exercise, user: user
        create :concept_solution,
          exercise: exercise_2,
          user: user,
          completed_at: Time.current,
          published_at: Time.current,
          mentoring_status: :requested

        wait_for_opensearch_to_be_synced

        use_capybara_host do
          sign_in!(user)
          visit solutions_journey_path
          click_on "Mentoring status"
          find("label", text: "Requested").click
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
        create :concept_solution, exercise: exercise, user: user, created_at: 2.days.ago
        create :concept_solution, exercise: exercise_2, user: user, created_at: 3.days.ago

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
