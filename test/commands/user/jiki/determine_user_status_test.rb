require 'test_helper'

class User::Jiki::DetermineUserStatusTest < ActiveSupport::TestCase
  test "returns false/false for nil user" do
    assert_equal({ is_insider: false, is_bootcamp_member: false }, User::Jiki::DetermineUserStatus.(nil))
  end

  %i[active active_lifetime].each do |status|
    test "is_insider true for #{status}" do
      user = create(:user)
      user.data.update!(insiders_status: status)

      assert User::Jiki::DetermineUserStatus.(user)[:is_insider]
    end
  end

  %i[unset ineligible eligible eligible_lifetime].each do |status|
    test "is_insider false for #{status}" do
      user = create(:user)
      user.data.update!(insiders_status: status)

      refute User::Jiki::DetermineUserStatus.(user)[:is_insider]
    end
  end

  test "is_bootcamp_member true for bootcamp_mentor" do
    user = create(:user, bootcamp_mentor: true)

    assert User::Jiki::DetermineUserStatus.(user)[:is_bootcamp_member]
  end

  test "is_bootcamp_member true when enrolled on part 1" do
    user = create(:user)
    create(:user_bootcamp_data, user:, enrolled_on_part_1: true)

    assert User::Jiki::DetermineUserStatus.(user)[:is_bootcamp_member]
  end

  test "is_bootcamp_member false when no bootcamp data" do
    user = create(:user)

    refute User::Jiki::DetermineUserStatus.(user)[:is_bootcamp_member]
  end
end
