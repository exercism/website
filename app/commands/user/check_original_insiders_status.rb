class User::CheckOriginalInsidersStatus
  include Mandate

  REPUTATION_THRESHOLD = 1_000
  DONATIONS_THRESHOLD = 500_00

  initialize_with :user

  def call
    return true if user.founder?
    return true if user.staff?
    return true if user.supermentor?
    return true if user.reputation >= REPUTATION_THRESHOLD
    return true if prelaunch_donation_total >= DONATIONS_THRESHOLD

    false
  end

  def prelaunch_donation_total
    user.donation_payments.where('created_at < ?', Date.new(2023, 5, 1)).sum(:amount_in_cents)
  end
end
