class Mentoring::ExternalController < ApplicationController
  before_action :ensure_not_mentor!

  def show; end

  def redirect_mentors!
    redirect_to mentor_dashboard_path
  end
end
