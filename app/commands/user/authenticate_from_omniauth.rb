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
          user.save!
        end

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
