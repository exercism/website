require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserRevealsABadgeTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user reveals a badge" do
      user = create :user
      create :user_acquired_badge, revealed: false, user: user

      use_capybara_host do
        sign_in!(user)
        visit badges_journey_url
        click_on "Unrevealed"
        within(".m-badge") { assert_text "Member" }
        page.find(".ReactModal__Overlay").click(x: 0, y: 0)

        assert_text "Member"
      end
    end
  end
end
