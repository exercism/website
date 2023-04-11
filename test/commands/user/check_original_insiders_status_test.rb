require "test_helper"

class User::CheckOriginalInsidersStatusTest < ActiveSupport::TestCase
  test "false for new users" do
    user = create :user
    refute User::CheckOriginalInsidersStatus.(user)
  end

  test "true for founder" do
    user = create :user, :founder
    assert User::CheckOriginalInsidersStatus.(user)
  end

  test "true for admins" do
    user = create :user, :admin
    assert User::CheckOriginalInsidersStatus.(user)
  end

  test "true for staff" do
    user = create :user, :staff
    assert User::CheckOriginalInsidersStatus.(user)
  end

  test "true for supermentor" do
    user = create :user, :supermentor
    assert User::CheckOriginalInsidersStatus.(user)
  end

  test "true for rep" do
    user = create :user, reputation: User::CheckOriginalInsidersStatus::REPUTATION_THRESHOLD - 1
    refute User::CheckOriginalInsidersStatus.(user)

    user = create :user, reputation: User::CheckOriginalInsidersStatus::REPUTATION_THRESHOLD
    assert User::CheckOriginalInsidersStatus.(user)
  end

  test "true for big prelaunch donor" do
    user = create :user
    create :donations_payment, user:, created_at: Date.new(2021, 1, 1), amount_in_cents: User::CheckOriginalInsidersStatus::DONATIONS_THRESHOLD - 1 # rubocop:disable Layout/LineLength
    create :donations_payment, user:, created_at: Date.new(2023, 5, 1), amount_in_cents: 1
    refute User::CheckInsidersStatus.(user)

    create :donations_payment, user:, created_at: Date.new(2022, 4, 30), amount_in_cents: 1
    assert User::CheckInsidersStatus.(user)
  end
end
