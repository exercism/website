class DashboardController < ApplicationController
  def show
    @user_tracks = current_user.user_tracks.sort_by { |ut| -ut.num_completed_exercises }
    @mentoring_inbox_size = 10 # TODO
    @featured_badges = current_user.badges.order('id desc').limit(4)
    @num_badges = current_user.badges.count
  end
end
