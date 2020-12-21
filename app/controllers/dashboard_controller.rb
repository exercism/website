class DashboardController < ApplicationController
  def show
    @user_tracks = current_user.user_tracks.sort_by { |ut| -ut.num_completed_exercises }
    @mentoring_inbox_size = 10 # TODO
  end
end
