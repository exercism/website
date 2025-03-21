class User::Bootstrap
  include Mandate

  initialize_with :user, bootcamp_access_code: nil

  def call
    user.auth_tokens.create!
    AwardBadgeJob.perform_later(user, :member)
    Metric::Queue.(:sign_up, user.created_at, user:)
    User::VerifyEmail.defer(user)

    link_courses_user!
  end

  private
  def link_courses_user!
    CourseEnrollment.where(email: user.email, user: nil).each do |ce|
      ce.update!(user:)
      ce.course.enable_for_user!(user)
    end
  end
end
