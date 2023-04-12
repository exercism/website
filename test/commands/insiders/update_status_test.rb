require 'test_helper'

class Insiders::UpdateStatusTest < ActiveSupport::TestCase
  [
    %i[ineligible ineligible],
    %i[eligible ineligible],
    %i[active expired],
    %i[expired expired],
    %i[lifetime_active lifetime_active]
  ].each do |(current_status, expected_status)|
    test "ineligble: insiders_status set to #{expected_status} when currently #{current_status}" do
      user = create :user, insiders_status: current_status

      Insiders::UpdateStatus.(user)

      assert_equal expected_status, user.insiders_status
    end
  end

  [
    %i[ineligible eligible],
    %i[eligible eligible],
    %i[active active],
    %i[expired active],
    %i[lifetime_active lifetime_active]
  ].each do |(current_status, expected_status)|
    test "eligble: insiders_status set to #{expected_status} when currently #{current_status}" do
      user = create :user, insiders_status: current_status

      # Make the user eligible
      user.update(active_donation_subscription: true)

      Insiders::UpdateStatus.(user)

      assert_equal expected_status, user.insiders_status
    end
  end
end
