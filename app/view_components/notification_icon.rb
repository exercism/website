class NotificationIcon < ViewComponent
  include Mandate

  initialize_with :user

  def to_s
    react_component("notification-icon", { count: user.notifications.count })
  end
end
