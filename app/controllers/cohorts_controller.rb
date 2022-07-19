class CohortsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :use_cohort

  def show
    @membership = current_user.cohort_memberships.find_by(cohort_slug: @cohort.slug) if user_signed_in?
  end

  def join
    begin
      current_user.cohort_memberships.create!(cohort_slug: @cohort.slug, introduction: params[:introduction])
    rescue ActiveRecord::RecordNotUnique
      # This is fine
    end

    redirect_to action: :show, anchor: "register"
  end

  private
  def use_cohort
    @cohort = COHORTS[params[:id].to_sym]

    render_404 if @cohort.blank?
  end

  Cohort = Struct.new(:slug, :name)
  COHORTS = { gohort: Cohort.new(:gohort, "Go-hort") }.freeze
  private_constant
end
