class User::InsidersStatus::DetermineEligibilityStatus
  include Mandate

  LIFETIME_REPUTATION_THRESHOLD = 1_000
  LIFETIME_DONATIONS_THRESHOLD = 499_00

  MONTHLY_REPUTATION_THRESHOLD = 30
  ANNUAL_REPUTATION_THRESHOLD = 200

  initialize_with :user

  def call
    return :eligible_lifetime if user.founder?
    return :eligible_lifetime if user.staff?
    return :eligible_lifetime if user.supermentor?
    return :eligible_lifetime if forever_reputation >= LIFETIME_REPUTATION_THRESHOLD
    return :eligible_lifetime if user.total_donated_in_cents >= LIFETIME_DONATIONS_THRESHOLD

    return :eligible if user.maintainer?
    return :eligible if active_prelaunch_subscription?
    return :eligible if monthly_reputation >= MONTHLY_REPUTATION_THRESHOLD
    return :eligible if annual_reputation >= ANNUAL_REPUTATION_THRESHOLD

    return :eligible if recent_donation?

    :ineligible
  end

  private
  def monthly_reputation = period_reputation(:month)
  def annual_reputation = period_reputation(:year)
  def forever_reputation = period_reputation(:forever)

  def period_reputation(period)
    User::ReputationPeriod::Search.new(
      period:,
      category: :any, # Auto-excludes publishing
      user_handle: user.handle
    ).period_records.to_a.sum(&:reputation)
  end

  def active_prelaunch_subscription?
    user.subscriptions.donation.where.not(status: :canceled).
      where('created_at < ?', LAUNCH_DATE).exists?
  end

  def recent_donation?
    user.payments.each do |donation|
      if donation.created_at < LAUNCH_DATE
        # For every 9.99 donation before Premium launched, give a month of access
        # from the launch date. Plus one free month for everyone who's ever donated.
        active_until = LAUNCH_DATE + (donation.amount_in_dollars / 9.99).floor.months + 1.month
      else
        # For any newer donations, they need to be $25 per month to get Insiders, and
        # then act from the date of the donation, not from launch
        active_until = donation.created_at + (donation.amount_in_dollars / 25).floor.months
      end

      return true if active_until > Time.current
    end

    false
  end

  LAUNCH_DATE = Date.new(2023, 5, 31).freeze
end
