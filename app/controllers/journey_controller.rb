class JourneyController < ApplicationController
  before_action :setup_hero

  def show; end

  def badges; end

  def setup_hero
    @user_tracks = current_user.user_tracks.sort_by { |ut| -ut.num_completed_exercises }
  end
end
