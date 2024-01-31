class User::WatchedVideo::Create
  include Mandate

  initialize_with :user, :video_provider, :video_id
  def call
    User::WatchedVideo.create_or_find_by!(
      user:, video_provider:, video_id:
    )
  end
end
