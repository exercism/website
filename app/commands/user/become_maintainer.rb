class User::BecomeMaintainer
  include Mandate

  initialize_with :user

  def call
    return if user.maintainer?

    User::AddRoles.(user, [:maintainer])
  end
end
