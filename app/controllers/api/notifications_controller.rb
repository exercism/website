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
        data: notifications.map(&:rendering_data),
        meta: {
          links: {
            all: Exercism::Routes.notifications_url
          },
          unread_count: current_user.notifications.unread.count
        }
      )

      render json: serialized
    end

    def mark_batch_as_read
      User::Notification::MarkBatchAsRead.(current_user, params[:uuids])

      render json: {}
    end

    def mark_batch_as_unread
      User::Notification::MarkBatchAsUnread.(current_user, params[:uuids])

      render json: {}
    end

    def mark_all_as_read
      User::Notification::MarkAllAsRead.(current_user)

      render json: {}
    end
  end
end
