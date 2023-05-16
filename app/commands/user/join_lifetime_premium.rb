class User::JoinLifetimePremium
  include Mandate

  initialize_with :user

  def call = User::JoinPremium.(user, Time.current + 100.years)
end
