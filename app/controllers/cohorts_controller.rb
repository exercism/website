class CohortsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @membership = current_user.cohort_memberships.first if user_signed_in?
  end

  def join
    begin
      current_user.cohort_memberships.create!(cohort_slug: "gohort", introduction: params[:introduction])
    rescue ActiveRecord::RecordNotUnique
      # This is fine
    end

    redirect_to action: :show, anchor: "register"
  end
end
