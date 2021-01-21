require "application_system_test_case"

module Components
  module Journey
    class SolutionsTest < ApplicationSystemTestCase
      test "shows solutions" do
        user = create :user
        track = create :track, title: "Ruby"
        exercise = create :concept_exercise, title: "Lasagna", track: track
        solution = create :concept_solution, exercise: exercise, completed_at: Time.current, user: user
        create :submission, solution: solution, created_at: 2.days.ago

        sign_in!(user)
        visit solutions_journey_path

        assert_text "Ruby"
        assert_text "Lasagna"
        assert_text "Completed"
        assert_text "1270 views"
        assert_text "10"
        assert_text "2"
        assert_text "3 iterations"
        assert_text "9 - 18 lines"
        assert_text "Last submitted 2 days ago"
        assert_link "Lasagna", href: Exercism::Routes.private_solution_url(solution)
        assert_icon track.icon_name
        assert_icon exercise.icon_name
      end

      test "paginates solutions" do
        Solution::Search.stubs(:per).returns(1)
        user = create :user
        exercise = create :concept_exercise, title: "Lasagna"
        exercise_2 = create :concept_exercise, title: "Bob"
        create :concept_solution, exercise: exercise, user: user
        create :concept_solution, exercise: exercise_2, user: user

        sign_in!(user)
        visit solutions_journey_path
        click_on "2"

        assert_text "Bob"
        assert_no_text "Lasagna"
      end

      private
      def assert_icon(name)
        assert_css "use[*|href=\"##{name}\"]"
      end
    end
  end
end
