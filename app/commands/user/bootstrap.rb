class User::Bootstrap
  include Mandate

  initialize_with :user, course_access_code: nil

  def call
    user.auth_tokens.create!
    AwardBadgeJob.perform_later(user, :member)
    Metric::Queue.(:sign_up, user.created_at, user:)
    User::VerifyEmail.defer(user)

    link_courses!
  end

  private
  def link_courses!
    enrollments = CourseEnrollment.where(email: user.email)
    enrollments = enrollments.or(CourseEnrollment.where(access_code: course_access_code)) if course_access_code.present?
    enrollments.each do |ce|
      next if ce.user

      ce.update!(user:)
      ce.course.enable_for_user!(user) if ce.paid?
    end
  end
end
