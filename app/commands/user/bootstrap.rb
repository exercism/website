class User
  class Bootstrap
    include Mandate

    initialize_with :user

    def call
      user.auth_tokens.create!
      AwardBadgeJob.perform_later(user, :member)
      Metric::Queue.(:sign_up, user.created_at, user:)
    end
  end
end
