class User::UpdateRoles
  include Mandate

  initialize_with :user, :roles

  def call
    user.update(roles:)
    User::SetDiscordRoles.(user)
  end
end
