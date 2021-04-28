require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module TrackMenu
      class ViewsTrackDocumentationTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "student views track documentation" do
          user = create :user
          track = create :track, title: "Ruby"
          create :concept_exercise, track: track
          create :user_track, user: user, track: track

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            click_on "Track menu"

            assert_link "Ruby documentation", href: track.documentation_url
          end
        end
      end
    end
  end
end
