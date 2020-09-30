class Test::Components::Notifications::IconController < Test::BaseController
  def show
    @user = User.first
  end

  def update
    NotificationsChannel.broadcast_changed(User.first, count: params[:count])
  end
end
