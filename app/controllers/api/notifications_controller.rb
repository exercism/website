module API
  class NotificationsController < BaseController
    def index
      notifications = User::Notification::Retrieve.(
        current_user,
        page: params[:page],
        per_page: params[:per_page]
      )

      render json: SerializePaginatedCollection.(
        notifications,
        SerializeUserNotifications
      )
    end
  end
end
