class User::Profile
  class Create
    include Mandate

    initialize_with :user

    def call
      raise ProfileCriteriaNotFulfilledError unless user.profile_unlocked?

      user.create_profile!
    end
  end
end
