class Mentoring::InboxController < ApplicationController
  before_action :ensure_mentor!

  def show
    @inbox_params = params.permit(:status, :order, :criteria, :page, :track_slug)
  end
end
