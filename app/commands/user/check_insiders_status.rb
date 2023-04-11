class User::CheckInsidersStatus
  include Mandate

  MONTHLY_REPUTATION_THRESHOLD = 30
  ANNUAL_REPUTATION_THRESHOLD = 200

  initialize_with :user

  def call
    return true if User::CheckOriginalInsidersStatus.(user)

    return true if user.maintainer?
    return true if user.active_donation_subscription?
    return true if monthly_reputation >= MONTHLY_REPUTATION_THRESHOLD
    return true if annual_reputation >= ANNUAL_REPUTATION_THRESHOLD

    false
  end

  private
  def monthly_reputation
    period_reputation(:month)
  end

  def annual_reputation
    period_reputation(:year)
  end

  def period_reputation(period)
    User::ReputationPeriod::Search.new(
      period:,
      category: :any, # Auto-excludes publishing
      user_handle: user.handle
    ).period_records.to_a.sum(&:reputation)
  end
end
