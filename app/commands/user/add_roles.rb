class User::AddRoles
  include Mandate

  initialize_with :user, :roles

  def call
    user.update(roles: user.roles + roles)

    User::SetDiscordRoles.(user)
    User::InsidersStatus::TriggerUpdate.(user)
  end
end
