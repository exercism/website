class CohortsController < ApplicationController
  def show
    @membership = current_user.cohort_memberships.first
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
