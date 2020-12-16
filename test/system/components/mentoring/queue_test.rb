require "application_system_test_case"
require_relative "../../../support/table_matchers"

module Components
  module Mentoring
    class QueueTest < ApplicationSystemTestCase
      include TableMatchers

      test "shows correct information" do
        visit test_components_mentoring_queue_url

        assert_css "img[src='https://assets.exercism.io/tracks/ruby-hex-white.png'][alt='icon for Ruby track']"
        assert_css "img[src='https://robohash.org/exercism'][alt=\"mentee's uploaded avatar\"]"
        assert_text "mentee"
        assert_text "on Series"
        assert_text "First timer"
        assert_text "a year ago"
        assert_link "", href: "https://exercism.io/solutions/1"
        assert_css "title", text: "Starred student", visible: false
        assert_css ".dot"
      end

      test "paginates results" do
        visit test_components_mentoring_queue_url
        click_on "2"

        assert_text "on Tournament"
      end

      test "shows error messages" do
        visit test_components_mentoring_queue_url
        select "Error", from: "State"
        click_on "Submit"

        assert_text "Something went wrong"
      end

      test "shows loading state" do
        visit test_components_mentoring_queue_url
        select "Loading", from: "State"
        click_on "Submit"

        within(".c-mentor-queue") { assert_text "Loading" }
      end

      test "filter by query" do
        visit test_components_mentoring_queue_url
        fill_in "Filter by student name", with: "Use"

        assert_text "User 2"
        assert_selector(".--solution", count: 1)
      end

      test "sort by student" do
        visit test_components_mentoring_queue_url
        select "Sort by Student", from: "mentoring-queue-sorter", exact: true

        assert_text "Frank"
      end
    end
  end
end
