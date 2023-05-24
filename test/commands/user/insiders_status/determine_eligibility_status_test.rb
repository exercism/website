require "test_helper"

class User::InsidersStatus::DetermineEligibilityStatusTest < ActiveSupport::TestCase
  test "ineligible for new users" do
    user = create :user
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "ineligible for post launch donor" do
    user = create :user
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    create :payments_payment, user:, created_at: Date.new(2023, 6, 3)

    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)
  end

  test "eligible_lifetime for founder" do
    user = create :user, :founder
    assert_equal :eligible_lifetime, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible_lifetime for admins" do
    user = create :user, :admin
    assert_equal :eligible_lifetime, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible_lifetime for staff" do
    user = create :user, :staff
    assert_equal :eligible_lifetime, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible_lifetime for supermentor" do
    user = create :user, :supermentor
    assert_equal :eligible_lifetime, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible_lifetime for lifetime rep" do
    user = create :user, reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD - 1
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    user = create :user, reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD
    assert_equal :eligible_lifetime, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible_lifetime for big pre launch donor" do
    user = create :user
    create :payments_payment, user:, created_at: Date.new(2023, 5, 1), amount_in_cents: 1
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)

    create :payments_payment, user:, created_at: Date.new(2021, 1, 1), amount_in_cents: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_DONATIONS_THRESHOLD - 1 # rubocop:disable Layout/LineLength
    assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)

    create :payments_payment, user:, created_at: Date.new(2022, 4, 30), amount_in_cents: 1
    assert_equal :eligible_lifetime, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)
  end

  test "eligible_lifetime for big post launch donor" do
    user = create :user
    create :payments_payment, user:, created_at: Date.new(2023, 6, 3), amount_in_cents: 499_00
    assert_equal :eligible_lifetime, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)
  end

  test "eligible for maintainer" do
    user = create :user, :maintainer
    assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible for pre launch donor" do
    user = create :user
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    create :payments_payment, user:, created_at: Date.new(2023, 4, 30)

    assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)
  end

  test "eligible for monthly rep" do
    user = create :user
    create :user_reputation_period, period: :month, about: :everything, category: :any,
      user:, reputation: User::InsidersStatus::DetermineEligibilityStatus::MONTHLY_REPUTATION_THRESHOLD - 1
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    user = create :user
    create :user_reputation_period, period: :month, about: :everything, category: :any,
      user:, reputation: User::InsidersStatus::DetermineEligibilityStatus::MONTHLY_REPUTATION_THRESHOLD
    assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible for annual rep" do
    user = create :user
    create :user_reputation_period, period: :year, about: :everything, category: :any,
      user:, reputation: User::InsidersStatus::DetermineEligibilityStatus::ANNUAL_REPUTATION_THRESHOLD - 1
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    user = create :user
    create :user_reputation_period, period: :year, about: :everything, category: :any,
      user:, reputation: User::InsidersStatus::DetermineEligibilityStatus::ANNUAL_REPUTATION_THRESHOLD
    assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end
end
