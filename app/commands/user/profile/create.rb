class User::Profile
  class Create
    include Mandate

    initialize_with :user

    def call = User::Profile.new(user:)
  end
end
