class User::JoinPremium
  include Mandate

  initialize_with :user, :premium_until

  def call
    user.update!(premium_until:)
  end
end
