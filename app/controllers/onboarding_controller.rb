class OnboardingController < ApplicationController
  skip_before_action :ensure_onboarded!

  before_action :authenticate_user!

  def show; end

  def update
    current_user.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)

    redirect_to after_sign_in_path_for(current_user)
  end
end
