class User::LinkWithDiscord
  include Mandate

  initialize_with :user, :auth

  def call
    set_uid!
  end

  private
  def set_uid!
    user.update!(discord_uid: uid)
  rescue ActiveRecord::RecordNotUnique
    old_user = User.find_by(discord_uid: uid)
    return if old_user == user

    old_user.update!(discord_uid: nil)
    user.update!(discord_uid: uid)
  end

  def uid
    auth.uid
  end
end
