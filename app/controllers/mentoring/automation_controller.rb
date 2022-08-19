class Mentoring::AutomationController < ApplicationController
  before_action :ensure_supermentor!

  def index
    @automation_params = params.permit(:order, :criteria, :page, :track_slug)
  end

  def with_feedback
    @automation_params = params.permit(:order, :criteria, :page, :track_slug)
  end
end
