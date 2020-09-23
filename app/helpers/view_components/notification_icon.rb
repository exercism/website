module ViewComponents
  class NotificationIcon < ViewComponent
    initialize_with :user

    def to_s
      react_component("notification-icon", { count: user.notifications.count })
    end
  end
end
