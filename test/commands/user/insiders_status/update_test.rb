require 'test_helper'

class User::InsidersStatus::UpdateTest < ActiveSupport::TestCase
  [
    %i[ineligible ineligible],
    %i[eligible ineligible],
    %i[active expired],
    %i[expired expired],
    %i[lifetime_active lifetime_active]
  ].each do |(current_status, expected_status)|
    test "ineligible: insiders_status set to #{expected_status} when currently #{current_status}" do
      user = create :user, insiders_status: current_status

      User::InsidersStatus::Update.(user)

      assert_equal expected_status, user.insiders_status
    end
  end

  [
    %i[ineligible eligible],
    %i[eligible eligible],
    %i[active active],
    %i[expired eligible],
    %i[lifetime_active lifetime_active]
  ].each do |(current_status, expected_status)|
    test "eligible: insiders_status set to #{expected_status} when currently #{current_status}" do
      user = create :user, insiders_status: current_status

      # Make the user eligible
      user.update(active_donation_subscription: true)

      User::InsidersStatus::Update.(user)

      assert_equal expected_status, user.insiders_status
    end
  end
end
