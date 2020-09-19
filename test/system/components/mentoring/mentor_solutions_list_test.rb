require "application_system_test_case"
require_relative "../../../support/table_matchers"

module Components
  module Mentoring
    class MentorSolutionsListTest < ApplicationSystemTestCase
      include TableMatchers

      test "shows correct information" do
        visit test_components_mentoring_mentor_solutions_list_url

        row = {
          "Track icon" => lambda {
            assert_css "img[src='https://assets.exercism.io/tracks/ruby-hex-white.png'][alt='icon indicating Ruby']"
          },
          "Mentee avatar" => -> { assert_css "img[src='https://robohash.org/exercism'][alt='avatar for mentee']" },
          "Mentee handle" => "mentee",
          "Exercise title" => "Series",
          "Starred?" => "true",
          "Mentored previously?" => "true",
          "Status" => "First timer",
          "Updated at" => "a year ago",
          "URL" => "https://exercism.io/solutions/1"
        }

        assert_table_row first("table"), row
      end

      test "paginates results" do
        visit test_components_mentoring_mentor_solutions_list_url
        click_on "2"

        row = { "Exercise title" => "Tournament" }

        assert_table_row first("table"), row
      end

      test "shows error messages" do
        visit test_components_mentoring_mentor_solutions_list_url
        select "Error", from: "State"
        click_on "Submit"

        assert_text "Something went wrong"
      end

      test "shows loading state" do
        visit test_components_mentoring_mentor_solutions_list_url
        select "Loading", from: "State"
        click_on "Submit"

        within(".mentor-solutions-list") { assert_text "Loading" }
      end

      test "filter by query" do
        visit test_components_mentoring_mentor_solutions_list_url
        fill_in "Filter by student name", with: "Use"

        row = { "Mentee handle" => "User 2" }

        assert_table_row first("table"), row

        assert_selector('.mentor-solutions-list tbody tr', count: 1)
      end

      test "sort by student" do
        visit test_components_mentoring_mentor_solutions_list_url
        select "Sort by Student", from: "Sort", exact: true

        row = { "Mentee handle" => "Frank" }

        assert_table_row first("table"), row
      end
    end
  end
end
