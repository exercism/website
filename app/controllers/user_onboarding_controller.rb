class UserOnboardingController < ApplicationController
  skip_before_action :ensure_onboarded!
  skip_before_action :store_user_location!

  def show
    return redirect_to dashboard_path if user_signed_in? && current_user.onboarded?

    @onboarding = UserOnboardingForm.new
  end

  def create
    @onboarding = UserOnboardingForm.new(
      user_onboarding_params.merge(user: current_user)
    )

    if @onboarding.save
      redirect_to after_sign_in_path_for(current_user)
    else
      render :show, status: :unprocessable_entity
    end
  end

  private
  def user_onboarding_params
    params.require(:user_onboarding_form).permit(:terms_of_service, :privacy_policy)
  end
end
