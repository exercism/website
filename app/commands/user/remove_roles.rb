class User::RemoveRoles
  include Mandate

  initialize_with :user, :roles

  def call
    user.update(roles: user.roles - roles)
    User::SetDiscordRoles.(user)
  end
end
