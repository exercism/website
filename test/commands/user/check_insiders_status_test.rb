require "test_helper"

class User::CheckInsidersStatusTest < ActiveSupport::TestCase
  test "false for new users" do
    user = create :user
    refute User::CheckInsidersStatus.(user)
  end

  test "true for originals" do
    user = create :user, :founder

    User::CheckOriginalInsidersStatus.expects(:call).with(user).returns(true)

    assert User::CheckInsidersStatus.(user)
  end

  test "true for maintainer" do
    user = create :user, :maintainer
    assert User::CheckInsidersStatus.(user)
  end

  test "true for regular donor" do
    user = create :user
    refute User::CheckInsidersStatus.(user)

    user.update(active_donation_subscription: true)
    assert User::CheckInsidersStatus.(user)
  end

  test "true for monthly rep" do
    user = create :user
    create :user_reputation_period, period: :month, about: :everything, category: :any,
      user:, reputation: User::CheckInsidersStatus::MONTHLY_REPUTATION_THRESHOLD - 1
    refute User::CheckInsidersStatus.(user)

    user = create :user
    create :user_reputation_period, period: :month, about: :everything, category: :any,
      user:, reputation: User::CheckInsidersStatus::MONTHLY_REPUTATION_THRESHOLD
    assert User::CheckInsidersStatus.(user)
  end

  test "true for annual rep" do
    user = create :user
    create :user_reputation_period, period: :year, about: :everything, category: :any,
      user:, reputation: User::CheckInsidersStatus::ANNUAL_REPUTATION_THRESHOLD - 1
    refute User::CheckInsidersStatus.(user)

    user = create :user
    create :user_reputation_period, period: :year, about: :everything, category: :any,
      user:, reputation: User::CheckInsidersStatus::ANNUAL_REPUTATION_THRESHOLD
    assert User::CheckInsidersStatus.(user)
  end
end
