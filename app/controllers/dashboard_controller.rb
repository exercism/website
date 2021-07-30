class DashboardController < ApplicationController
  def show
    @user_tracks = current_user.user_tracks.order(last_touched_at: :desc).limit(3)
    @featured_badges = current_user.badges.order('id desc').limit(4)
    @num_badges = current_user.badges.count
    @updates = SiteUpdate.published.for_user(current_user).sorted.limit(10)
    @blog_posts = BlogPost.published.ordered_by_recency.limit(3).includes(:author)

    if current_user.mentor? # rubocop:disable Style/GuardClause
      @mentor_discussions = Mentor::Discussion::Retrieve.(
        current_user,
        :awaiting_mentor,
        sorted: false,
        paginated: false
      ).limit(5)

      @mentor_queue_has_requests = Mentor::Request::Retrieve.(
        mentor: current_user,
        sorted: false,
        paginated: false
      ).exists?
    end
  end
end
