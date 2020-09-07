class Test::Components::Notifications::IconsController < ApplicationController
  def show
    @user = User.first
  end

  def update
    NotificationsChannel.broadcast_to(
      User.first,
      { type: "notifications.changed", payload: { count: params[:count] } }
    )
  end
end
