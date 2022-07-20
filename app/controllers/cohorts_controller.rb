class CohortsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :use_cohort

  def show
    @membership = CohortMembership.find_by(user: current_user, cohort: @cohort) if user_signed_in?
  end

  def join
    Cohort::Join.(current_user, @cohort, params[:introduction])

    redirect_to action: :show, anchor: "register"
  end

  private
  def use_cohort
    @cohort = ::Cohort.find_by!(slug: params[:id])

    user_track = UserTrack.for(@current_user, @cohort.track)
    @num_concepts = user_track.num_concepts
    @num_exercises = user_track.num_exercises
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
