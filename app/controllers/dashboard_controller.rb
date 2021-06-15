class DashboardController < ApplicationController
  def show
    @user_tracks = current_user.user_tracks.order(last_touched_at: :desc).limit(3)
    @num_mentor_discussions = current_user.mentor_discussions.awaiting_mentor.count
    @mentor_discussions = current_user.mentor_discussions.awaiting_mentor.limit(5)
    @featured_badges = current_user.badges.order('id desc').limit(4)
    @num_badges = current_user.badges.count
    @updates = SiteUpdate.published.for_user(current_user).sorted.limit(10)
  end
end
