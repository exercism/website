require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Profile
    class UserViewsContributionsSummaryTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows contribution summary" do
        user = create :user, handle: "user"
        create(:user_profile, user:)
        create(:user_code_contribution_reputation_token, user:)
        generate_reputation_periods!

        use_capybara_host do
          visit profile_path(user.handle)

          assert_text "user has 12 Reputation"
          assert_text "Building"
          assert_text "1 PR accepted"
          assert_text "12 rep"
          assert_link "See user's contributions", href: contributions_profile_url(user.handle)
        end
      end
    end
  end
end
