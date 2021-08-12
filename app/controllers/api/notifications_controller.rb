module API
  class NotificationsController < BaseController
    def index
      render json: AssembleNotificationsList.(current_user, list_params)
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

    private
    def list_params
      params.permit(AssembleNotificationsList.keys)
    end
  end
end
