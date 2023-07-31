require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  class UserViewsProfileTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows only revealed badges" do
      author = create :user
      create :user_profile, user: author
      create :user_acquired_badge, user: author, badge: create(:member_badge), revealed: true
      create :user_acquired_badge, user: author, badge: create(:rookie_badge), revealed: false
      create :user_acquired_badge, user: author, badge: create(:supporter_badge), revealed: true

      use_capybara_host do
        visit profile_path(author.handle)

        assert_text "2 badges collected"
        within('.badges') do
          assert_selector('.c-badge', count: 2)
          assert_selector("img[alt='Badge: Member']")
          refute_selector("img[alt='Badge: Rookie']")
          assert_selector("img[alt='Badge: Supporter']")
        end
      end
    end

    test "shows (escaped) bio" do
      author = create :user, bio: 'Programming is my passion! <img src="x">'
      create :user_profile, user: author

      use_capybara_host do
        visit profile_path(author.handle)

        assert_text author.bio
      end
    end
  end
end
