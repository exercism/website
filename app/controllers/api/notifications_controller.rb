class API::NotificationsController < API::BaseController
  skip_before_action :ensure_onboarded!, only: [:index]

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

    render json: AssembleNotificationsList.(current_user, list_params)
  end

  private
  def list_params
    params.permit(*AssembleNotificationsList.keys)
  end
end
