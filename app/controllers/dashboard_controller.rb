class DashboardController < ApplicationController
  def show
    @user_tracks = current_user.user_tracks.order(last_touched_at: :desc).limit(3).includes(track: :concepts)
    @num_user_tracks = current_user.user_tracks.count
    @featured_badges = current_user.revealed_badges.order('id desc').limit(4)
    @num_badges = current_user.revealed_badges.count
    @updates = SiteUpdate.published.for_user(current_user).sorted.limit(10).includes(:author, exercise: :track)
    @blog_posts = BlogPost.published.ordered_by_recency.limit(3).includes(:author)

    @live_event = StreamingEvent.live.first
    @featured_event = StreamingEvent.next_featured unless @live_event
    @scheduled_events = StreamingEvent.next_5

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
