require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Donations
    class UserDonationSummaryTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user views donation summary" do
        user = create :user, total_donated_in_cents: 3200
        subscription = create :payments_subscription, user:, status: :active, amount_in_cents: 1000
        create(:payments_payment, user:, amount_in_cents: 1000, subscription:)
        create :payments_payment, user:, amount_in_cents: 2200

        use_capybara_host do
          sign_in!(user)
          visit donations_settings_path

          assert_text "You're currently donating $10.00 each month to Exercism"
          assert_text "$10.00 from recurring"
          assert_text "$22.00 from one-time"
        end
      end
    end
  end
end
