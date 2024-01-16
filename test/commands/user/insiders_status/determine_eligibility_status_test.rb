require "test_helper"

class User::InsidersStatus::DetermineEligibilityStatusTest < ActiveSupport::TestCase
  test "ineligible for basic users" do
    user = create :user
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)
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

    user = create :user
    create :user_reputation_period, period: :forever, about: :everything, category: :building,
      user:, reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD
    assert_equal :eligible_lifetime, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible_lifetime for lifetime rep counts reputation for all non-any category" do
    user = create :user

    create(:user_reputation_period, reputation: 5, period: :forever, about: :everything, category: :building, user:)
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    create(:user_reputation_period, reputation: 170, period: :forever, about: :everything, category: :maintaining, user:)
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    create(:user_reputation_period, reputation: 290, period: :forever, about: :everything, category: :authoring, user:)
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    create(:user_reputation_period, reputation: 600, period: :forever, about: :everything, category: :mentoring, user:)
    assert_equal :eligible_lifetime, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible_lifetime for lifetime rep ignores publishing reputation" do
    user = create :user

    # The 'any' category includes publishing reputation
    create :user_reputation_period, period: :forever, about: :everything, category: :any,
      user:, reputation: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_REPUTATION_THRESHOLD
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible_lifetime for large donor" do
    user = create :user, total_donated_in_cents: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_DONATIONS_THRESHOLD - 1
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)

    user = create :user, total_donated_in_cents: User::InsidersStatus::DetermineEligibilityStatus::LIFETIME_DONATIONS_THRESHOLD
    assert_equal :eligible_lifetime, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)
  end

  test "eligible for maintainer" do
    user = create :user, :maintainer
    assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible for active_prelaunch_subscription" do
    # Get away from any special logic that happens just after launch with old donations
    travel_to(Date.new(2024, 1, 1)) do
      # Prelaunch but canceled
      user = create :user
      create(:payments_subscription, status: :canceled, created_at: Date.new(2022, 6, 1), user:)
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)

      # Prelaunch and active
      user = create :user
      create(:payments_subscription, status: :active, created_at: Date.new(2022, 6, 1), user:)
      assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)

      # Prelaunch and overdue
      user = create :user
      create(:payments_subscription, status: :overdue, created_at: Date.new(2022, 6, 1), user:)
      assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)
    end
  end

  test "eligible for active_subscription" do
    # Canceled
    user = create :user
    create(:payments_subscription, status: :canceled, user:)
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)

    # Active but too small
    user = create :user
    create(:payments_subscription, status: :active, user:, amount_in_cents: Insiders::MINIMUM_AMOUNT_IN_CENTS - 1)
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)

    # Overdue
    user = create :user
    create(:payments_subscription, status: :overdue, user:)
    assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)

    # Active
    user = create :user
    create(:payments_subscription, status: :active, user:, amount_in_cents: Insiders::MINIMUM_AMOUNT_IN_CENTS)
    assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user.reload)
  end

  test "eligible for monthly rep" do
    user = create :user
    create :user_reputation_period, period: :month, about: :everything, category: :building,
      user:, reputation: User::InsidersStatus::DetermineEligibilityStatus::MONTHLY_REPUTATION_THRESHOLD - 1
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    user = create :user
    create :user_reputation_period, period: :month, about: :everything, category: :building,
      user:, reputation: User::InsidersStatus::DetermineEligibilityStatus::MONTHLY_REPUTATION_THRESHOLD
    assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible for monthly rep counts reputation for all non-any category" do
    user = create :user

    create(:user_reputation_period, reputation: 5, period: :month, about: :everything, category: :building, user:)
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    create(:user_reputation_period, reputation: 7, period: :month, about: :everything, category: :maintaining, user:)
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    create(:user_reputation_period, reputation: 9, period: :month, about: :everything, category: :authoring, user:)
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    create(:user_reputation_period, reputation: 11, period: :month, about: :everything, category: :mentoring, user:)
    assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible for annual rep" do
    user = create :user
    create :user_reputation_period, period: :year, about: :everything, category: :building,
      user:, reputation: User::InsidersStatus::DetermineEligibilityStatus::ANNUAL_REPUTATION_THRESHOLD - 1
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)

    user = create :user
    create :user_reputation_period, period: :year, about: :everything, category: :building,
      user:, reputation: User::InsidersStatus::DetermineEligibilityStatus::ANNUAL_REPUTATION_THRESHOLD
    assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible ignores publishing reputation" do
    user = create :user

    # The 'any' category includes publishing reputation
    create :user_reputation_period, period: :year, about: :everything, category: :any,
      user:, reputation: User::InsidersStatus::DetermineEligibilityStatus::ANNUAL_REPUTATION_THRESHOLD
    assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user)
  end

  test "eligible for prelaunch donations" do
    user_tiny_donation = create :user
    create :payments_payment, amount_in_cents: 1, created_at: Date.new(2023, 5, 1), user: user_tiny_donation

    user_15 = create :user
    create :payments_payment, amount_in_cents: 15_00, created_at: Date.new(2023, 5, 1), user: user_15

    user_25 = create :user
    create :payments_payment, amount_in_cents: 25_00, created_at: Date.new(2023, 5, 1), user: user_25

    travel_to(Date.new(2023, 6, 1)) do
      assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user_tiny_donation.reload)
      assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user_15.reload)
      assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user_25.reload)
    end

    travel_to(Date.new(2023, 7, 1)) do
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user_tiny_donation.reload)
      assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user_15.reload)
      assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user_25.reload)
    end

    travel_to(Date.new(2023, 8, 1)) do
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user_tiny_donation.reload)
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user_15.reload)
      assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user_25.reload)
    end

    travel_to(Date.new(2023, 9, 1)) do
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user_tiny_donation.reload)
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user_15.reload)
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user_25.reload)
    end
  end

  test "eligible for postlaunch donations" do
    user_tiny_donation = create :user
    create :payments_payment, amount_in_cents: 1, created_at: Date.new(2023, 6, 1), user: user_tiny_donation

    user_10 = create :user
    create :payments_payment, amount_in_cents: 10_00, created_at: Date.new(2023, 6, 1), user: user_10

    user_100 = create :user
    create :payments_payment, amount_in_cents: 100_00, created_at: Date.new(2023, 6, 1), user: user_100

    # Next day
    travel_to(Date.new(2023, 6, 2)) do
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user_tiny_donation.reload)
      assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user_10.reload)
      assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user_100.reload)
    end

    # Longer than a month + grace period
    travel_to(Date.new(2023, 7, 30)) do
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user_tiny_donation.reload)
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user_10.reload)
      assert_equal :eligible, User::InsidersStatus::DetermineEligibilityStatus.(user_100.reload)
    end

    # Longer than a year + grace period
    travel_to(Date.new(2024, 6, 30)) do
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user_tiny_donation.reload)
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user_10.reload)
      assert_equal :ineligible, User::InsidersStatus::DetermineEligibilityStatus.(user_100.reload)
    end
  end
end
