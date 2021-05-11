class Mentoring::QueueController < ApplicationController
  before_action :ensure_mentor!

  def show
    @queue_params = params.permit(:order, :criteria, :page, :track_slug, :exercise_slug)
  end
end
