class CommunityController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    # TODO: add caching
    @supporter_avatar_urls =
      User.supporter.
        with_attached_avatar.
        where.not('users.avatar_url': nil).
        order(first_donated_at: :desc).
        pluck(:avatar_url).
        last(40)

    @community_stories = CommunityStory.published.includes(:interviewee).ordered_by_recency.first(3)
    @forum_threads = Forum::RetrieveThreads.(type: :top, count: 1)
  end
end
