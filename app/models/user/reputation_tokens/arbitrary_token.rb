class User::ReputationTokens::ArbitraryToken < User::ReputationToken
  params :arbitrary_value, :arbitrary_reason
  category :misc

  before_validation on: :create do
    self.earned_on = Time.current unless earned_on
    self.reason = arbitrary_reason unless reason
  end

  def guard_params = SecureRandom.uuid

  def i18n_params
    { reason: }
  end

  protected
  def determine_value = arbitrary_value
end
