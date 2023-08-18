class User::Notifications::AcquiredTrophyNotification < User::Notification
  params :user_track_acquired_trophy

  delegate :track, :trophy, to: :user_track_acquired_trophy

  before_validation on: :create do
    self.track = user_track_acquired_trophy.track
  end

  def url = Exercism::Routes.track_url(track, anchor: "trophy-cabinet")
  def image_type = :icon
  def image_path = "graphics/#{trophy.icon}.svg"
  def icon_filter = "none"
  def guard_params = "Track##{track.id}|Trophy##{trophy.id}"

  def i18n_params
    {
      track_title: track.title,
      trophy_name: trophy.name(track)
    }
  end
end
