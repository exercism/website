module API
  class NotificationsController < BaseController
    def index
      notifications = User::Notification::Retrieve.(
        current_user,
        page: params[:page],
        per_page: params[:per_page]
      )

      serialized = SerializePaginatedCollection.(
        notifications,
        SerializeUserNotifications
      )

      # This feels pretty gross.
      serialized[:unrevealed_badges] = SerializeUserAcquiredBadges.(current_user.unrevealed_badges)

      render json: serialized
    end
  end
end
