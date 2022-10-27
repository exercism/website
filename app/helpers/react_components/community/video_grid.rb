class ReactComponents::Community::VideoGrid < ReactComponents::ReactComponent
  def initialize(params)
    super()

    @params = params
  end

  def to_s
    super(
      "community-video-grid",
      {
        request: {
          endpoint: Exercism::Routes.api_community_videos_url,
          query:,
          options: {
            initial_data:
          }
        },
        tracks:
      }
    )
  end

  private
  attr_reader :params

  memoize
  def initial_data = AssembleCommunityVideos.(params)

  memoize
  def tracks
    tracks = ::Track.where(id: CommunityVideo.approved.select(:track_id))

    AssembleTracksForSelect.(tracks)
  end

  memoize
  def query
    {
      video_page: current_page,
      track_slug: params[:video_track_slug],
      criteria: params[:criteria]
    }.compact
  end

  memoize
  def current_page
    page = initial_data[:meta][:current_page]

    page != 1 ? page : nil
  end
end
