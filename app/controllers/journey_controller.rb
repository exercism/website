class JourneyController < ApplicationController
  before_action :setup_hero

  def show; end

  def solutions
    @solutions = current_user.solutions
  end

  def badges
    @badges = current_user.badges
  end

  def reputation
    @reputation_tokens = current_user.reputation_tokens
  end

  def setup_hero
    @user_tracks = current_user.user_tracks.includes(:track).sort_by { |ut| -ut.num_completed_exercises }
  end
end
