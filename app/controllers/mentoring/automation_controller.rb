class Mentoring::AutomationController < ApplicationController
  before_action :ensure_supermentor!

  def index
    @automation_params = params.permit(:order, :criteria, :page, :track_slug, :only_mentored_solutions)
  end

  def with_feedback
    @automation_params = params.permit(:order, :criteria, :page, :track_slug)
  end

  def edit
    @representation = Exercise::Representation.find(params[:id])
    @examples = Exercise::Representation::FindExampleSubmissions.(@representation)
  end
end
