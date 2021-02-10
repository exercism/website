class SerializeNotifications
  include Mandate

  initialize_with :notifications

  def call
    notifications.
      map { |r| serialize_notification(r) }
  end

  private
  def serialize_notification(notification)
    {
      # TODO: Maybe expose a UUID instead?
      id: notification.id,
      text: notification.text,
      read: notification.read?,
      created_at: notification.created_at,
      image_type: "avatar", # TODO: Work this out for icons
      image_url: notification.user.avatar_url,
      url: notification.url
    }
  end
end
