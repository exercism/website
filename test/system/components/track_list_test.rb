require "application_system_test_case"
require_relative "../../support/table_matchers"

module Components
  class TrackListTest < ApplicationSystemTestCase
    include TableMatchers

    test "shows tracks" do
      visit test_components_track_list_url

      row = {
        "Track icon" => lambda {
          assert_css "img[src='https://assets.exercism.io/tracks/ruby-hex-white.png'][alt='icon for Ruby track']"
        },
        "Track title" => "Ruby",
        "Exercise count" => 20,
        "Concept exercise count" => 10,
        "Practice exercise count" => 10,
        "Student count" => 10,
        "New?" => "true",
        "Joined?" => "true",
        "Tags" => "OOP, Web Dev",
        "Completed exercise count" => 15,
        "Progress %" => "66.67",
        "URL" => "https://exercism.io/tracks/1"
      }

      assert_table_row first("table"), row
    end
  end
end
