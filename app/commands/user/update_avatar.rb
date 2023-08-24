class User::UpdateAvatar
  include Mandate

  initialize_with :user, :avatar

  def call
    user.update!(
      avatar:,
      version: user.version + 1
    )

    User::InvalidateAvatarInCloudfront.defer(user)
  end
end