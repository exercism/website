require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  class UserViewsBadgesTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows badges" do
      author = create :user
      create :user_profile, user: author
      create :user_acquired_badge, user: author, badge: create(:member_badge), revealed: true
      create :user_acquired_badge, user: author, badge: create(:rookie_badge)

      use_capybara_host do
        visit badges_profile_path(author.handle)

        assert_text "Member"
        refute_text "Rookie"
        assert_text "1 Common"
      end
    end
  end
end
