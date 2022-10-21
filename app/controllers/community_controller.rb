class CommunityController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    # TODO: add caching
    @supporter_avatar_urls =
      User::AcquiredBadge.joins(:user).
        where(badge_id: Badge.find_by_slug!("supporter")). # rubocop:disable Rails/DynamicFindBy
        where(users: { show_on_supporters_page: true }).
        last(40).
        map { |b| b.user.avatar_url }

    @community_stories = CommunityStory.includes(:interviewee).ordered_by_recency.first(3)
  end
end
