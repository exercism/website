class User
  class AuthenticateFromOmniauth
    include Mandate

    initialize_with :auth

    def call
      user = User.find_by(provider: auth.provider, uid: auth.uid)

      if user
        if user.email.ends_with?("@users.noreply.github.com")
          user.email = auth.info.email
          user.skip_reconfirmation!
          user.save
        end

        return user
      end

      user = User.find_by(email: auth.info.email)
      if user
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

        user.save

        return user
      end

      user = User.new(
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        password: Devise.friendly_token[0, 20],
        name: auth.info.name,
        handle: auth.info.nickname
      )

      user.skip_confirmation!
      user.save

      user
    end
  end
end
