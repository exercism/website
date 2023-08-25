class User::IncrementVersion
  include Mandate

  initialize_with :user

  def call
    User.where(id: user.id).update_all("version = version + 1")
    user.reload # We might want to immediately use this version downstream
    User::InvalidateAvatarInCloudfront.defer(user)
  end
end
