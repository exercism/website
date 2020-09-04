class Test::Components::Notifications::IconsController < ApplicationController
  def show
    @user = User.first
  end

  def create_notification
    NotificationsChannel.broadcast_to(User.first, { type: "notification.created" })
  end
end
