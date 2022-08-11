class Mentoring::AutomationController < ApplicationController
  before_action :ensure_mentor!

  def index
    # TODO: use the actual correct parameters for automation
    @automation_params = params.permit(:status, :order, :criteria, :page, :track_slug)
  end
end
