require "application_system_test_case"
require_relative "../../../support/table_matchers"

module Components
  module Mentoring
    class MentorInboxTest < ApplicationSystemTestCase
      include TableMatchers

      test "shows correct information" do
        visit test_components_mentoring_mentor_inbox_url

        row = {
          "Track icon" => lambda {
            assert_css "img[src='https://assets.exercism.io/tracks/ruby-hex-white.png'][alt='icon indicating Ruby']"
          },
          "Mentee avatar" => -> { assert_css "img[src='https://robohash.org/exercism'][alt='avatar for mentee']" },
          "Mentee handle" => "mentee",
          "Exercise title" => "Series",
          "Starred?" => "true",
          "Mentored previously?" => "true",
          "New iteration?" => "true",
          "Posts count" => "15",
          "Updated at" => "a year ago",
          "URL" => "https://exercism.io/conversations/1"
        }

        assert_table_row first("table"), row
      end

      test "paginates results" do
        visit test_components_mentoring_mentor_inbox_url
        click_on "2"

        row = { "Exercise title" => "Tournament" }

        assert_table_row first("table"), row
      end

      test "filters by track" do
        visit test_components_mentoring_mentor_inbox_url
        select "Ruby", from: "Track"

        ruby_row = {
          "Track icon" => lambda {
            assert_css "img[src='https://assets.exercism.io/tracks/ruby-hex-white.png'][alt='icon indicating Ruby']"
          }
        }
        go_row = {
          "Track icon" => lambda {
            refute_css "img[src='https://assets.exercism.io/tracks/go-hex-white.png'][alt='icon indicating Go']"
          }
        }

        assert_table_row first("table"), ruby_row
        assert_table_row first("table"), go_row
      end

      test "handles API errors" do
        visit test_components_mentoring_mentor_inbox_url
        select "Error", from: "State"
        click_on "Submit"

        assert_text "Something went wrong"
      end

      test "shows loading state" do
        visit test_components_mentoring_mentor_inbox_url
        select "Loading", from: "State"
        click_on "Submit"

        assert_text "Loading"
      end

      test "handles API errors" do
        visit test_components_mentoring_mentor_conversations_list_url
        select "Error", from: "State"
        click_on "Submit"

        assert_text "Something went wrong"
      end

      test "shows loading state" do
        visit test_components_mentoring_mentor_conversations_list_url
        select "Loading", from: "State"
        click_on "Submit"

        assert_text "Loading"
      end
    end
  end
end
