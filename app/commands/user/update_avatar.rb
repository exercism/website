class User::UpdateAvatar
  include Mandate

  initialize_with :user, :avatar

  def call
    user.update!(avatar:)

    User::IncrementVersion.(user)
  end
end
