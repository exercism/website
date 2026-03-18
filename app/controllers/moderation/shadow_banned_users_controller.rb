class Moderation::ShadowBannedUsersController < Moderation::BaseController
  def index
    @users = User.includes(:shadow_banned_by).where.not(shadow_banned_at: nil).order(shadow_banned_at: :desc)
  end

  def create
    handle = params[:handle]&.strip
    user = User.find_by(handle: handle)

    if user.nil?
      flash[:alert] = "Could not find user with handle '#{handle}'"
    elsif user.shadow_banned?
      flash[:alert] = "#{user.handle} is already shadow banned"
    else
      user.update!(shadow_banned_at: Time.current, shadow_banned_by_id: current_user.id)
      flash[:notice] = "#{user.handle} has been shadow banned from mentoring"
    end

    redirect_to moderation_shadow_banned_users_path
  end

  def destroy
    user = User.find_by!(handle: params[:id])
    user.update!(shadow_banned_at: nil, shadow_banned_by_id: nil)
    flash[:notice] = "Shadow ban removed for #{user.handle}"
    redirect_to moderation_shadow_banned_users_path
  end
end
