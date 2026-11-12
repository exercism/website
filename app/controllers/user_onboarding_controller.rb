class UserOnboardingController < ApplicationController
  skip_before_action :ensure_onboarded!

  def show
    return redirect_to dashboard_path if user_signed_in? && current_user.onboarded?

    respond_to do |format|
      format.html do
        # People who sign up through GitHub from the sign-in page create their
        # account without seeing the sign-up questions, so they answer them
        # here before the terms.
        next render :questions if needs_sign_up_answers?

        @onboarding = UserOnboardingForm.new
      end
      format.any { head :not_acceptable }
    end
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

  def update
    if needs_sign_up_answers?
      User::SetSignUpAnswers.(current_user, seniority: params[:seniority],
        sign_up_track_slug: params[:sign_up_track_slug])
    end

    redirect_to user_onboarding_path
  end

  private
  def needs_sign_up_answers?
    user_signed_in? && !current_user.onboarded? && current_user.seniority.nil?
  end

  def user_onboarding_params
    params.require(:user_onboarding_form).permit(:terms_of_service, :privacy_policy)
  end
end
