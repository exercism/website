class Mentoring::AutomationController < ApplicationController
  before_action :ensure_mentor!

  def index
    @automation_params = params.permit(:order, :criteria, :page, :track_slug)
  end

  def without_feedback
    @automation_params = params.permit(:order, :criteria, :page, :track_slug)
  end
end
