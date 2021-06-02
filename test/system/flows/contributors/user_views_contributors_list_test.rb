require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Contributors
    class UserViewsContributorsListTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user views contributor list" do
        create :user
        contributor = create :user, handle: "contributor"
        token = create :user_reputation_token, user: contributor, value: 10
        User::ReputationPeriod::MarkForNewToken.(token)
        User::ReputationPeriod::Sweep.()

        use_capybara_host do
          visit contributing_contributors_path

          assert_text "contributor"
          assert_text "1 PR created"
          assert_text "12"
        end
      end

      test "user filters by period" do
        create :user
        contributor = create :user, handle: "contributor"
        week_token = create :user_reputation_token, user: contributor, value: 10, earned_on: Time.zone.today
        User::ReputationPeriod::MarkForNewToken.(week_token)
        month_token = create :user_reputation_token, user: contributor, value: 10, earned_on: 2.months.ago
        User::ReputationPeriod::MarkForNewToken.(month_token)
        User::ReputationPeriod::Sweep.()

        use_capybara_host do
          visit contributing_contributors_path
          click_on "Last 7 days"

          assert_text "1 PR created"
        end
      end
    end
  end
end
