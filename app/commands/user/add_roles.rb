class User::AddRoles
  include Mandate

  initialize_with :user, :roles

  def call
    user.data.with_lock do
      user.update(roles: user.roles + roles)
    end
    User::SetDiscordRoles.(user)
    User::InsidersStatus::TriggerUpdate.(user)
  end
end
