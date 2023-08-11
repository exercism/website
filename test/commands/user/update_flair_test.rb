require 'test_helper'

class User::UpdateFlairTest < ActiveSupport::TestCase
  %i[unset ineligible eligible eligible_lifetime].each do |insiders_status|
    test "don't update flair when insiders_status is #{insiders_status}" do
      user = create(:user, insiders_status:)

      User::UpdateFlair.(user)

      assert_nil user.flair
    end
  end

  test "update flair to founder if user is founder" do
    user = create :user, :founder

    User::UpdateFlair.(user)

    assert_equal :founder, user.flair
  end

  %i[admin staff].each do |role|
    test "update flair to staff if user is #{role}" do
      user = create :user, role

      User::UpdateFlair.(user)

      assert_equal :staff, user.flair
    end
  end

  test "update flair to insider if user is active insider" do
    user = create :user, insiders_status: :active

    User::UpdateFlair.(user)

    assert_equal :insider, user.flair
  end

  test "update flair to lifetime_insider if user is lifetime insider" do
    user = create :user, insiders_status: :active_lifetime

    User::UpdateFlair.(user)

    assert_equal :lifetime_insider, user.flair
  end
end
