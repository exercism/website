require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Journey
    class BadgesTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows badges" do
        user = create :user
        rookie_badge = create :rookie_badge
        create(:user_acquired_badge, revealed: true, badge: rookie_badge, user:)

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
        create(:user_acquired_badge, revealed: true, badge: member_badge, user:)
        rookie_badge = create :rookie_badge
        create(:user_acquired_badge, revealed: true, badge: rookie_badge, user:)

        use_capybara_host do
          sign_in!(user)
          visit badges_journey_path

          assert_text "Showing 2 badges"
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
        create(:user_acquired_badge, revealed: true, badge: rookie_badge, user:)
        member_badge = create :member_badge
        create(:user_acquired_badge, revealed: true, badge: member_badge, user:)

        use_capybara_host do
          sign_in!(user)
          visit badges_journey_path
          click_on "Sort by Unrevealed First"
          find("label", text: "Sort by Oldest First").click

          assert_no_text "Member"
          assert_text "Rookie"
        end
      end

      test "searches badges" do
        user = create :user
        rookie_badge = create :rookie_badge
        create :user_acquired_badge, revealed: true, badge: rookie_badge, user:, created_at: 1.day.ago
        member_badge = create :member_badge
        create :user_acquired_badge, revealed: true, badge: member_badge, user:, created_at: 2.days.ago

        use_capybara_host do
          sign_in!(user)
          visit badges_journey_path
          fill_in "Search by badge name or description", with: "Rook"

          assert_no_text "Member"
          assert_text "Rookie"
        end
      end

      test "works on refresh" do
        user = create :user
        rookie_badge = create :rookie_badge
        create :user_acquired_badge, revealed: true, badge: rookie_badge, user:, created_at: 1.day.ago
        member_badge = create :member_badge
        create :user_acquired_badge, revealed: true, badge: member_badge, user:, created_at: 2.days.ago

        use_capybara_host do
          sign_in!(user)
          visit badges_journey_path(order: "unrevealed_first", criteria: "Rook")

          assert_no_text "Member"
          assert_text "Rookie"
        end
      end
    end
  end
end
