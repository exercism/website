require "application_system_test_case"

module Flows
  class JoinTrackTestTest < ApplicationSystemTestCase
    test "joins track when authenticated" do
      user = create :user
      track = create :track, slug: "ruby", title: "Ruby"

      # TODO: Add when adding devise
      # sign_in(user)

      visit tracks_url
      click_link "Ruby"

      click_on "Join Track"

      assert_equal [track], user.tracks
    end
  end
end
