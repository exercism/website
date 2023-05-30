class User::InsidersStatus::DetermineEligibilityStatus
  include Mandate

  LIFETIME_REPUTATION_THRESHOLD = 1_000
  LIFETIME_DONATIONS_THRESHOLD = 499_00
  LIFETIME_PREMIUM_AMOUNT = 499_00

  MONTHLY_REPUTATION_THRESHOLD = 30
  ANNUAL_REPUTATION_THRESHOLD = 200

  initialize_with :user

  def call
    return :eligible_lifetime if user.founder?
    return :eligible_lifetime if user.staff?
    return :eligible_lifetime if user.supermentor?
    return :eligible_lifetime if user.reputation >= LIFETIME_REPUTATION_THRESHOLD
    return :eligible_lifetime if prelaunch_donation_total >= LIFETIME_DONATIONS_THRESHOLD
    return :eligible_lifetime if lifetime_premium_donation?

    return :eligible if user.maintainer?
    return :eligible if prelaunch_donation_total.positive?
    return :eligible if monthly_reputation >= MONTHLY_REPUTATION_THRESHOLD
    return :eligible if annual_reputation >= ANNUAL_REPUTATION_THRESHOLD

    :ineligible
  end

  private
  def monthly_reputation = period_reputation(:month)
  def annual_reputation = period_reputation(:year)

  def period_reputation(period)
    User::ReputationPeriod::Search.new(
      period:,
      category: :any, # Auto-excludes publishing
      user_handle: user.handle
    ).period_records.to_a.sum(&:reputation)
  end

  def prelaunch_donation_total
    user.payments.donation.where('created_at < ?', LAUNCH_DATE).sum(:amount_in_cents)
  end

  def lifetime_premium_donation?
    user.payments.where('amount_in_cents >= ?', LIFETIME_PREMIUM_AMOUNT).exists?
  end

  LAUNCH_DATE = Date.new(2023, 5, 31).freeze
end
