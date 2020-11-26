class Test::Components::NotificationsIconsController < Test::BaseController
  def show
    @user = User.first
  end

  def update
    NotificationsChannel.broadcast_changed(User.first, count: params[:count].to_i)
  end
end
