class Mentoring::AutomationController < ApplicationController
  before_action :ensure_supermentor!, except: :tooltip_locked

  def index
    @automation_params = params.permit(:order, :criteria, :page, :track_slug, :only_mentored_solutions)
  end

  def with_feedback
    @automation_params = params.permit(:order, :criteria, :page, :track_slug)
  end

  def edit
    @representation = Exercise::Representation.find_by!(uuid: params[:uuid])
    @examples = Exercise::Representation::FindExampleSubmissions.(@representation)
    @source_params = params.permit(source: [:order, :criteria, :page, :track_slug, :only_mentored_solutions]).fetch(:source)
  end

  def tooltip_locked
    @finished_mentoring_sessions = @current_user.mentor_discussions.finished.count
    @satisfaction_percentage = @current_user.mentor_satisfaction_percentage.to_i
    @min_finished_mentoring_sessions = Mentor::Supermentor::MIN_FINISHED_MENTORING_SESSIONS
    @min_satisfaction_percentage = Mentor::Supermentor::MIN_SATISFACTION_PERCENTAGE

    render_template_as_json
  end
end
