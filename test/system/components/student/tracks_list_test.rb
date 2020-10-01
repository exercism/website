require "application_system_test_case"

module Components
  module Student
    class TracksListTest < ApplicationSystemTestCase
      include TableMatchers

      def setup
        super

        # This component uses the API, which requires authentication
        sign_in!
      end

      test "shows tracks" do
        track = create :track, title: "Ruby"
        concept_exercises = Array.new(10).map { create :concept_exercise, track: track }
        practice_exercises = Array.new(10).map { create :practice_exercise, track: track }
        create :user_track, track: track, user: @current_user
        concept_exercises.sample(5).map { |ex| create :concept_solution, user: @current_user, exercise: ex }
        practice_exercises.sample(5).map { |ex| create :practice_solution, user: @current_user, exercise: ex }

        visit test_components_student_tracks_list_url

        row = {
          "Icon" => lambda {
            assert_css "img[src='https://assets.exercism.io/tracks/ruby-hex-white.png'][alt='icon for Ruby track']"
          },
          "Title" => "Ruby",
          "Num concept exercises" => 10,
          "Num practice exercises" => 10,
          "URL" => "https://test.exercism.io/tracks/ruby",
          "New?" => "true",
          "Tags" => "OOP, Web Dev",
          "Joined?" => "true",
          "Num completed concept exercises" => 5,
          "Num completed practice exercises" => 5,
          "Progress" => "Completed concept exercises: 25%, Uncompleted concept exercises: 25%, "\
                        "Completed practice exercises: 25%, Uncompleted practice exercises: 25%"
        }
        assert_table_row first("table"), row
      end

      test "filter by track title" do
        create :track, title: "Ruby"
        create :track, title: "Go"

        visit test_components_student_tracks_list_url
        fill_in "Search language tracks", with: "Go"

        row = { "Title" => "Go" }
        assert_table_row first("table"), row
        assert_selector(".student-track-list tbody tr", count: 1)
      end

      test "filter by status" do
        create :track, title: "Ruby"
        go = create :track, title: "Go"
        create :user_track, track: go, user: @current_user

        visit test_components_student_tracks_list_url
        select "Joined", from: "Status"

        row = { "Title" => "Go" }
        assert_table_row first("table"), row
        assert_selector(".student-track-list tbody tr", count: 1)
      end

      test "shows empty state" do
        visit test_components_student_tracks_list_url

        assert_text "No results found"
      end

      test "shows loading state" do
        visit test_components_student_tracks_list_url
        select "Loading", from: "State"
        click_on "Submit"

        assert_text "Loading"
      end

      test "shows error state" do
        visit test_components_student_tracks_list_url
        select "Error", from: "State"
        click_on "Submit"

        assert_text "Something went wrong"
      end
    end
  end
end
