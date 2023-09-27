class Mentoring::AutomationController < ApplicationController
  before_action :ensure_automator!, except: :tooltip_locked
  before_action :use_representation!, only: %i[edit]

  def index
    @automation_params = params.permit(:order, :criteria, :page, :track_slug, :only_mentored_solutions)
  end

  def with_feedback
    @automation_params = params.permit(:order, :criteria, :page, :track_slug)
  end

  def admin
    @automation_params = params.permit(:order, :criteria, :page, :track_slug, :only_mentored_solutions)
  end

  def edit
    @examples = Exercise::Representation::FindExampleSubmissions.(@representation)
    @source_params = params.permit(source: %i[order criteria page track_slug only_mentored_solutions])[:source] || {}
  end

  def tooltip_locked
    @finished_mentoring_sessions = @current_user.track_mentorships.maximum(:num_finished_discussions).to_i
    @satisfaction_percentage = @current_user.mentor_satisfaction_percentage.to_i
    @min_finished_mentoring_sessions = User::UpdateSupermentorRole::MIN_FINISHED_MENTORING_SESSIONS
    @min_satisfaction_percentage = User::UpdateSupermentorRole::MIN_SATISFACTION_PERCENTAGE

    render_template_as_json
  end

  private
  def use_representation!
    @representation = Exercise::Representation.find_by!(uuid: params[:uuid])
    return unless @representation.track

    redirect_to mentoring_path unless current_user.automator?(@representation.track)
  end
end
