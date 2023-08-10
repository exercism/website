class User::InsidersStatus::DetermineEligibilityStatus
  include Mandate

  LIFETIME_REPUTATION_THRESHOLD = 1_000
  LIFETIME_DONATIONS_THRESHOLD = Insiders::LIFETIME_AMOUNT_IN_CENTS

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
    return :eligible if active_subscription?
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
    user.reputation_periods.where(
      period:,
      category: %i[building maintaining authoring mentoring],
      about: :everything,
      track_id: 0
    ).sum(:reputation)
  end

  def active_prelaunch_subscription?
    user.subscriptions.where.not(status: :canceled).
      where('created_at < ?', Insiders::LAUNCH_DATE).exists?
  end

  def active_subscription?
    user.subscriptions.where.not(status: :canceled).
      where('amount_in_cents >= ?', Insiders::MINIMUM_AMOUNT_IN_CENTS).exists?
  end

  def recent_donation?
    user.payments.sort { |p| -p.id }.each do |donation|
      # For every 9.99 donation before Insiders launched, give a month of access
      # from the launch date. Plus one free month for everyone who's ever donated.
      if donation.created_at < Insiders::LAUNCH_DATE
        active_until = Insiders::LAUNCH_DATE + (donation.amount_in_dollars / 9.99).floor.months + 1.month

        # Annual payment: One year donation + grace period
      elsif donation.amount_in_cents >= Insiders::YEAR_AMOUNT_IN_CENTS
        active_until = donation.created_at + 1.year + Insiders::GRACE_PERIOD

        # Monthly payment: A month + grace period
      elsif donation.amount_in_cents >= Insiders::MINIMUM_AMOUNT_IN_CENTS
        active_until = donation.created_at + 1.month + Insiders::GRACE_PERIOD

      # Else the donation is too small to be considered
      else
        next
      end

      return true if active_until > Time.current
    end

    false
  end
end
