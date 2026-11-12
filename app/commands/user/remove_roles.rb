class User::RemoveRoles
  include Mandate

  initialize_with :user, :roles do
    @roles = roles.to_set
  end

  def call
    return if roles.disjoint?(user.roles)

    was_staff = user.staff?
    user.update(roles: user.roles - roles)

    User::SetDiscordRoles.defer(user)
    User::InsidersStatus::TriggerUpdate.(user)
    Analytics::IdentifyUser.defer(user) if user.staff? != was_staff
  end
end
