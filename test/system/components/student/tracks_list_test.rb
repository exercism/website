require "application_system_test_case"

module Components
  module Student
    class TracksListTest < ApplicationSystemTestCase
      setup do
        sign_in!
      end

      test "filter by track title" do
        create :track, :random_slug, title: "Ruby"
        create :track, :random_slug, title: "Go"

        visit test_components_student_tracks_list_url
        fill_in "Search language tracks", with: "Go"

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

        assert_text "Ruby"
        assert_text "Go"
      end

      test "shows empty state" do
        visit test_components_student_tracks_list_url

        assert_text "No results found"
      end
    end
  end
end
