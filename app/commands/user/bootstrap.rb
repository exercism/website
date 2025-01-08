class User::Bootstrap
  include Mandate

  initialize_with :user, bootcamp_access_code: nil

  def call
    user.auth_tokens.create!
    AwardBadgeJob.perform_later(user, :member)
    Metric::Queue.(:sign_up, user.created_at, user:)
    User::VerifyEmail.defer(user)

    link_bootcamp_user!
  end

  private
  def link_bootcamp_user!
    ubd = User::BootcampData.find_by(access_code: bootcamp_access_code) if bootcamp_access_code.present?
    ubd ||= User::BootcampData.find_by(email: user.email)
    return unless ubd

    User::LinkWithBootcampData.(user, ubd)
  end
end
