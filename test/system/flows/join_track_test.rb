require "application_system_test_case"

module Flows
  class JoinTrackTestTest < ApplicationSystemTestCase
    test "joins track when authenticated" do
      # TODO: Unskip once this issue is resolved:
      # https://github.com/exercism/website/issues/143
      skip

      user = create :user
      track = create :track, title: "Ruby"

      sign_in!(user)

      visit tracks_url

      click_link "Ruby"

      click_on "Join Track"

      assert_equal [track], user.tracks
    end
  end
end
