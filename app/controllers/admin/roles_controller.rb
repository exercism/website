class Admin::RolesController < Admin::BaseController
  before_action :ensure_admin!
  before_action :use_user_and_role, only: %i[create destroy]

  def index
    @role = params[:role].presence&.to_sym
    @role = nil unless User::Roles::ASSIGNABLE.include?(@role)
    @users = User::RetrieveRoleHolders.(role: @role, page: params[:page])
  end

  def create
    User::AddRoles.(@user, [@role])
    redirect_back_to_roles notice: "#{@user.handle} now has the #{User::Roles.label(@role)} role."
  end

  def destroy
    if @user == current_user && @role == :admin
      return redirect_back_to_roles alert: "You can't remove your own admin role. Ask another admin to do it."
    end

    User::RemoveRoles.(@user, [@role])
    redirect_back_to_roles notice: "#{@user.handle} no longer has the #{User::Roles.label(@role)} role."
  end

  private
  def use_user_and_role
    @role = params[:role].to_s.to_sym
    return redirect_back_to_roles alert: "Choose a role." unless User::Roles::ASSIGNABLE.include?(@role)

    handle = (params[:handle] || params[:id]).to_s.strip
    @user = User.find_by(handle:)
    redirect_back_to_roles alert: "Could not find a user with the handle \"#{handle}\"." unless @user
  end

  # The forms send the list's filter and page, so the admin
  # lands back on the list they were looking at.
  def redirect_back_to_roles(**flash)
    redirect_to admin_roles_path(role: params[:filter_role].presence, page: params[:page].presence), **flash
  end
end
