class User::IncrementVersion
  include Mandate

  initialize_with :user

  def call
    User.where(id: user.id).update_all("version = version + 1")
    user.reload # We might want to immediately use this version downstream

    # Let's just let the TTL take care of this. But I'll leave
    # it here for now (2025/06/03).
    # User::InvalidateAvatarInCloudfront.defer(user)
  end
end
