class CohortsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :use_cohort

  def show
    @membership = current_user.cohort_memberships.find_by(cohort: @cohort) if user_signed_in?
  end

  def join
    Cohort::Join.(current_user, @cohort, params[:introduction])

    redirect_to action: :show, anchor: "register"
  end

  private
  def use_cohort
    @cohort = ::Cohort.find_by(slug: params[:id])
    render_404 if @cohort.blank?

    user_track = UserTrack.for(@current_user, @cohort.track)
    @num_concepts = user_track.num_concepts
    @num_exercises = user_track.num_exercises
  end
end
