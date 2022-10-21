class AssembleCommunityVideos
  include Mandate

  initialize_with :params

  def call
    SerializePaginatedCollection.(
      videos,
      serializer: SerializeCommunityVideos,
      meta: {
        unscoped_total: CommunityVideo.approved.count
      }
    )
  end

  memoize
  def videos
    CommunityVideo::Search.(
      criteria: params[:criteria],
      page: params[:page],
      track:
    )
  end

  memoize
  def track
    Track.find(params[:track_slug]) if params[:track_slug].present?
  end
end
