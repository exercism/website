class Tracks::MentorDiscussionsController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_solution
  before_action :use_discussion, only: :show

  def index
    return redirect_to track_exercise_path(@track, @exercise) unless @solution&.iterated?

    @previous_discussions = @solution.mentor_discussions.includes(:mentor).
      where(status: %i[finished student_timed_out mentor_timed_out])
  end

  def show; end

  def tooltip_locked = render_template_as_json

  private
  def use_discussion
    raise ActiveRecord::RecordNotFound unless @solution

    @discussion = @solution.mentor_discussions.includes(
      :student, :mentor
    ).find_by!(uuid: params[:id])
  end
end
