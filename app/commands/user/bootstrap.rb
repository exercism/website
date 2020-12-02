class User
  class Bootstrap
    include Mandate

    initialize_with :user

    def call
      user.auth_tokens.create!
    end
  end
end
