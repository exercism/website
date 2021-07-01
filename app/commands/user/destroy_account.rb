class User
  class DestroyAccount
    include Mandate

    initialize_with :user

    def call
      User::ResetAccount.(user)
      user.destroy
    end
  end
end
