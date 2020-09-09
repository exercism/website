require "application_system_test_case"

module Components
  module Mentoring
    class MentorConversationsListTest < ApplicationSystemTestCase
      test "shows correct information" do
        visit test_components_mentoring_mentor_conversations_list_url

        within("tbody > tr:first-child") do
          within("td:nth-child(1)") { assert_css "img[src='https://assets.exercism.io/tracks/ruby-hex-white.png']" }
          within("td:nth-child(2)") { assert_css "img[src='https://robohash.org/exercism']" }
          within("td:nth-child(3)") { assert_text "mentee" }
          within("td:nth-child(4)") { assert_text "Series" }
          within("td:nth-child(5)") { assert_text "true" }
          within("td:nth-child(6)") { assert_text "true" }
          within("td:nth-child(7)") { assert_text "true" }
          within("td:nth-child(8)") { assert_text "15" }
          within("td:nth-child(9)") { assert_text "a year ago" }
          within("td:nth-child(10)") { assert_text "https://exercism.io/conversations/1" }
        end
      end
    end
  end
end
