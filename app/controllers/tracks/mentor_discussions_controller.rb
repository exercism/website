class Tracks::MentorDiscussionsController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_solution
  before_action :use_discussion, only: :show

  def index
    return redirect_to track_exercise_path(@track, @exercise) unless @solution&.iterated?

    @previous_discussions = @solution.mentor_discussions.finished.includes(mentor: { avatar_attachment: :blob })
  end

  def show; end

  def tooltip_locked = render_template_as_json

  private
  def use_discussion
    raise ActiveRecord::RecordNotFound unless @solution

    @discussion = @solution.mentor_discussions.includes(
      student: { avatar_attachment: :blob },
      mentor: { avatar_attachment: :blob }
    ).find_by!(uuid: params[:id])
  end
end
