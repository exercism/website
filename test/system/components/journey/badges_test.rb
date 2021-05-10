require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Journey
    class BadgesTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows badges" do
        user = create :user
        rookie_badge = create :rookie_badge
        create :user_acquired_badge, revealed: true, badge: rookie_badge, user: user

        use_capybara_host do
          sign_in!(user)
          visit badges_journey_path

          assert_text "Rookie"
        end
      end

      test "paginates badges" do
        User::AcquiredBadge::Search.stubs(:default_per).returns(1)
        user = create :user
        member_badge = create :member_badge
        create :user_acquired_badge, revealed: true, badge: member_badge, user: user
        rookie_badge = create :rookie_badge
        create :user_acquired_badge, revealed: true, badge: rookie_badge, user: user

        use_capybara_host do
          sign_in!(user)
          visit badges_journey_path
          assert_no_text "Member"
          assert_text "Rookie"

          click_on "2"
          assert_no_text "Rookie"
          assert_text "Member"
        end
      end

      test "sorts badges" do
        User::AcquiredBadge::Search.stubs(:default_per).returns(1)
        user = create :user
        rookie_badge = create :rookie_badge
        create :user_acquired_badge, revealed: true, badge: rookie_badge, user: user
        member_badge = create :member_badge
        create :user_acquired_badge, revealed: true, badge: member_badge, user: user

        use_capybara_host do
          sign_in!(user)
          visit badges_journey_path
          select "Sort by Oldest First"
          assert_no_text "Member"
          assert_text "Rookie"

          click_on "2"
          assert_no_text "Rookie"
          assert_text "Member"
        end
      end

      test "searches badges" do
        user = create :user
        rookie_badge = create :rookie_badge
        create :user_acquired_badge, revealed: true, badge: rookie_badge, user: user, created_at: 1.day.ago
        member_badge = create :member_badge
        create :user_acquired_badge, revealed: true, badge: member_badge, user: user, created_at: 2.days.ago

        use_capybara_host do
          sign_in!(user)
          visit badges_journey_path
          fill_in "Search for a badge", with: "Rook"

          assert_no_text "Member"
          assert_text "Rookie"
        end
      end
    end
  end
end
