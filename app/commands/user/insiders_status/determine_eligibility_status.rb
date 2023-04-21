class User::InsidersStatus::DetermineEligibilityStatus
  include Mandate

  LIFETIME_REPUTATION_THRESHOLD = 1_000
  LIFETIME_DONATIONS_THRESHOLD = 500_00

  MONTHLY_REPUTATION_THRESHOLD = 30
  ANNUAL_REPUTATION_THRESHOLD = 200

  initialize_with :user

  def call
    return :eligible_lifetime if user.founder?
    return :eligible_lifetime if user.staff?
    return :eligible_lifetime if user.supermentor?
    return :eligible_lifetime if user.reputation >= LIFETIME_REPUTATION_THRESHOLD
    return :eligible_lifetime if prelaunch_donation_total >= LIFETIME_DONATIONS_THRESHOLD

    return :eligible if user.maintainer?
    return :eligible if user.active_donation_subscription?
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
    user.donation_payments.where('created_at < ?', Date.new(2023, 5, 1)).sum(:amount_in_cents)
  end
end
