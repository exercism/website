class SerializeUserNotifications
  include Mandate

  initialize_with :notifications

  def call
    notifications.map(&:rendering_data)
  end
end
