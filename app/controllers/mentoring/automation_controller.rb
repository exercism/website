class Mentoring::AutomationController < ApplicationController
  before_action :ensure_supermentor!, except: :tooltip_locked
  before_action :use_representation!, only: %i[edit]

  def index
    @automation_params = params.permit(:order, :criteria, :page, :track_slug, :only_mentored_solutions)
  end

  def with_feedback
    @automation_params = params.permit(:order, :criteria, :page, :track_slug)
  end

  def edit
    @examples = Exercise::Representation::FindExampleSubmissions.(@representation)
    @source_params = params.permit(source: %i[order criteria page track_slug only_mentored_solutions])[:source] || {}
  end

  def tooltip_locked
    @finished_mentoring_sessions = @current_user.mentor_discussions.finished.count
    @satisfaction_percentage = @current_user.mentor_satisfaction_percentage.to_i
    @min_finished_mentoring_sessions = Mentor::Supermentor::MIN_FINISHED_MENTORING_SESSIONS
    @min_satisfaction_percentage = Mentor::Supermentor::MIN_SATISFACTION_PERCENTAGE

    render_template_as_json
  end

  private
  def use_representation!
    @representation = Exercise::Representation.find_by!(uuid: params[:uuid])
    return unless @representation.track

    redirect_to mentoring_path unless Mentor::Supermentor.for_track?(current_user, @representation.track)
  end
end
