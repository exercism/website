class User::UpdateAvatar
  include Mandate

  initialize_with :user, :avatar

  def call
    user.update!(avatar:)

    User::InvalidateAvatarInCloudfront.defer(user)
  end
end
