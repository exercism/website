require "application_system_test_case"

module Components
  module Student
    class TracksListTest < ApplicationSystemTestCase
      setup do
        sign_in!
      end

      test "renders correctly for unjoined track" do
        create :track,
          title: "Ruby",
          tags: ["foo/bar", "abc/xyz"]

        visit test_components_student_tracks_list_url

        assert_text 'Ruby', within: ".c-tracks-list"
      end

      test "renders correctly for joined track" do
        track = create :track,
          title: "Ruby",
          tags: ["foo/bar", "abc/xyz"]
        concept_exercises = Array.new(3).map { create :concept_exercise, track: track }
        practice_exercises = Array.new(4).map { create :practice_exercise, track: track }
        create :user_track, track: track, user: @current_user
        concept_exercises.sample(1).map { |ex| create :concept_solution, user: @current_user, exercise: ex }
        practice_exercises.sample(2).map { |ex| create :practice_solution, user: @current_user, exercise: ex }

        visit test_components_student_tracks_list_url

        assert_text 'Ruby', within: ".c-tracks-list"
        assert_text 'Joined', within: ".c-tracks-list"

        # TODO: Recheck for this:
        # <div class="--progress-bar">
        #   <div class="--cp" style="width: 14.2857%;"></div>
        #   <div class="--ucp" style="width: 28.5714%;"></div>
        #   <div class="--ce" style="width: 28.5714%;"></div>
        #   <div class="--uce" style="width: 28.5714%;"></div>
        # </div>
        # ', within: ".c-tracks-list"
      end

      test "filter by track title" do
        create :track, :random_slug, title: "Ruby"
        create :track, :random_slug, title: "Go"

        visit test_components_student_tracks_list_url
        fill_in "Search language tracks", with: "Go"

        assert_selector(".c-tracks-list .--track", count: 1)
        assert_text "Go", within: ".--track"
      end

      test "filter by status" do
        create :track, :random_slug, title: "Ruby"
        go = create :track, :random_slug, title: "Go"
        create :user_track, track: go, user: @current_user

        visit test_components_student_tracks_list_url
        click_on "Joined20", exact: true

        assert_selector(".c-tracks-list .--track", count: 1)
        assert_text "Go", within: ".--track"
      end

      test "filter by tag" do
        create :track, :random_slug, title: "Ruby", tags: ["paradigm/object_oriented", "typing/dynamic"]
        create :track, :random_slug, title: "Go", tags: ["paradigm/object_oriented", "typing/static"]

        visit test_components_student_tracks_list_url
        click_on "Filter by"
        check "Object-oriented"
        check "Dynamic"
        click_on "Apply"

        assert_text "Showing 1 track"
        assert_selector(".c-tracks-list .--track", count: 1)
        assert_text "Ruby", within: ".--track"
      end

      test "resets filters" do
        create :track, :random_slug, title: "Ruby", tags: ["paradigm/object_oriented", "typing/dynamic"]
        create :track, :random_slug, title: "Go", tags: ["paradigm/object_oriented", "typing/static"]

        visit test_components_student_tracks_list_url
        click_on "Filter by"
        check "Object-oriented"
        check "Dynamic"
        click_on "Apply"
        click_on "Reset filters"

        assert_text "Exercism's Language Tracks"
        assert_text "Ruby"
        assert_text "Go"
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
