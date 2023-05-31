class CommunityVideo::Search
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 12

  initialize_with track: nil, criteria: nil, page: DEFAULT_PAGE, per: DEFAULT_PER

  def call
    @videos = CommunityVideo.approved
    filter_criteria!
    filter_track!
    sort!
    paginate!
    @videos
  end

  private
  attr_reader :videos

  def filter_criteria!
    return if criteria.blank?

    criteria.strip.split(" ").each do |crit|
      @videos = @videos.left_joins(:author).where("community_videos.title LIKE ?", "%#{crit}%").
        or(@videos.left_joins(:author).where("users.handle LIKE ?", "%#{crit}%"))
    end
  end

  def filter_track!
    return if track.blank?

    @videos = @videos.where(track:)
  end

  def sort!
    @videos = @videos.order(published_at: :desc)
  end

  def paginate!
    @videos = @videos.page(page).per(per)
  end
end
