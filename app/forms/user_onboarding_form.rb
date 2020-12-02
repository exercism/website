class UserOnboardingForm
  include ActiveModel::Model

  attr_accessor :user, :accepted_privacy_policy_at, :accepted_terms_at

  validates :terms_of_service, acceptance: true
  validates :privacy_policy, acceptance: true

  def save
    return unless valid?

    user.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
  end
end
