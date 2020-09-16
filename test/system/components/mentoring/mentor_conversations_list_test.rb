require "application_system_test_case"
require_relative "../../../support/table_matchers"

module Components
  module Mentoring
    class MentorConversationsListTest < ApplicationSystemTestCase
      include TableMatchers

      test "shows correct information" do
        visit test_components_mentoring_mentor_conversations_list_url

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
    end
  end
end
