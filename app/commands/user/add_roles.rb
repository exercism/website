class User::AddRoles
  include Mandate

  initialize_with :user, :roles do
    @roles = roles.to_set
  end

  def call
    return if roles.subset?(user.roles)

    user.update(roles: user.roles + roles)

    User::SetDiscordRoles.defer(user)
    User::InsidersStatus::TriggerUpdate.(user)
  end
end
