class ReactComponents::Community::VideoGrid < ReactComponents::ReactComponent
  initialize_with :params, items_per_row: 4, show_title: true

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
        tracks:,
        items_per_row:,
        show_title:
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
      video_track_slug: params[:video_track_slug],
      criteria: params[:criteria]
    }.compact
  end

  memoize
  def current_page
    page = initial_data[:meta][:current_page]

    page != 1 ? page : nil
  end
end
