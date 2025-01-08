class User::Bootstrap
  include Mandate

  initialize_with :user

  def call
    user.auth_tokens.create!
    AwardBadgeJob.perform_later(user, :member)
    Metric::Queue.(:sign_up, user.created_at, user:)
    User::VerifyEmail.defer(user)

    link_bootcamp_user!
  end

  private
  def link_bootcamp_user!
    ubd = User::BootcampData.find_by(email: user.email)
    return unless ubd

    ubd.update!(user:)
    User::Bootcamp::SubscribeToOnboardingEmails.defer(ubd)

    return unless ubd.paid?

    user.update!(bootcamp_attendee: true)
  end
end
