require "application_system_test_case"
require_relative "../../../support/table_matchers"

module Components
  module Mentoring
    class InboxTest < ApplicationSystemTestCase
      include TableMatchers

      test "shows correct information" do
        visit test_components_mentoring_inbox_url

        assert_css "img[src='https://assets.exercism.io/tracks/ruby-hex-white.png'][alt='icon for Ruby track']"
        assert_css "img[src='https://robohash.org/exercism'][alt=\"Mentee's uploaded avatar\"]"
        assert_text "Mentee"
        assert_text "on Series"
        assert_text "New Iteration"
        assert_text "15"
        assert_text "a year ago"
        assert_link "", href: "https://exercism.io/conversations/1"
        assert_css "title", text: "Starred student", visible: false
      end

      test "paginates results" do
        visit test_components_mentoring_inbox_url
        click_on "2"

        assert_text "on Tournament"
      end

      test "filters by track" do
        visit test_components_mentoring_inbox_url
        select "Ruby", from: "track-filter-track", exact: true

        assert_css "img[src='https://assets.exercism.io/tracks/ruby-hex-white.png'][alt='icon for Ruby track']"
        refute_css "img[src='https://assets.exercism.io/tracks/go-hex-white.png'][alt='icon for Go track']"
      end

      test "filter by query" do
        visit test_components_mentoring_inbox_url
        fill_in "conversation-filter", with: "Tourn"

        assert_text "on Tournament"
        assert_selector('.--conversations .--solution', count: 1)
      end

      test "sort by student" do
        visit test_components_mentoring_inbox_url
        select "Sort by Student", from: "conversation-sorter-sort", exact: true

        assert_text "Frank"
      end

      test "handles conversations endpoint API errors" do
        visit test_components_mentoring_inbox_url
        select "Error", from: "Conversations endpoint state"
        click_on "Submit"

        assert_text "Something went wrong"
      end

      test "shows conversations endpoint API loading state" do
        visit test_components_mentoring_inbox_url
        select "Loading", from: "Conversations endpoint state"
        click_on "Submit"

        within(".c-mentor-inbox") { assert_text "Loading" }
      end

      test "handles tracks endpoint API errors" do
        visit test_components_mentoring_inbox_url
        select "Error", from: "Tracks endpoint state"
        click_on "Submit"

        assert_text "Something went wrong"
      end

      test "shows tracks endpoint API loading state" do
        visit test_components_mentoring_inbox_url
        select "Loading", from: "Tracks endpoint state"
        click_on "Submit"

        within(".track-filter") { assert_text "Loading" }
      end
    end
  end
end
