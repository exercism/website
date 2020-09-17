class NotificationIcon < ViewComponent
  def render(user)
    react_component("notification-icon", { count: user.notifications.count })
  end
end
