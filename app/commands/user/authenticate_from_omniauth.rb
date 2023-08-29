class User::AuthenticateFromOmniauth
  include Mandate

  initialize_with :auth

  def call
    find_by_uid || find_by_email || create
  end

  def find_by_uid
    user = User.find_by(provider: auth.provider, uid: auth.uid)
    return nil unless user

    if user.email.ends_with?("@users.noreply.github.com")
      user.email = auth.info.email
      user.skip_reconfirmation!
      user.save!
    end

    # Ensure this is done after the normal save as this failing
    # shouldn't cause the whole model's save to fail
    User::SetGithubUsername.(user, auth.info.nickname)

    user.update_column(:avatar_url, auth.info.image) if user.attributes['avatar_url'].blank?
    user
  end

  def find_by_email
    user = User.find_by(email: auth.info.email)
    return nil unless user

    user.provider = auth.provider
    user.uid = auth.uid

    # If the user was not previously confirmed then
    # we need to confirm them so they don't get blocked
    # when trying to log in.
    unless user.confirmed?
      user.confirmed_at = Time.current

      # We need to protect against:
      # - Malicious person signs up with email/password
      # - Real user oauths + confirms account
      # - Malicious person can now use original password
      #   to sign in
      new_password = SecureRandom.uuid
      user.reset_password(new_password, new_password)
    end

    # Make this a bang-save because if it's not we can get errors
    # on a dirty object further down the chain.
    user.save!

    # Ensure this is done after the normal save as this failing
    # shouldn't cause the whole model's save to fail
    User::SetGithubUsername.(user, auth.info.nickname)

    user
  end

  def create
    user = User.new(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: Devise.friendly_token[0, 20],
      name: auth.info.name,
      avatar_url: auth.info.image,
      handle:
    )

    user.skip_confirmation!

    if user.save
      # Ensure this is done after the normal save as this failing
      # shouldn't cause the whole model's save to fail
      User::SetGithubUsername.(user, auth.info.nickname)

      User::Bootstrap.(user)
    end

    user
  end

  private
  def handle
    attempt = auth.info.nickname
    attempt = "#{auth.info.nickname}-#{SecureRandom.random_number(10_000)}" while User.where(handle: attempt).exists?
    attempt
  end
end
