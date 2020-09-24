class Test::Components::Notifications::IconController < ApplicationController
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
