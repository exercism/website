class User::Bootstrap
  include Mandate

  initialize_with :user, course_access_code: nil, locale: nil, accept_language: nil

  def call
    set_locale!
    user.auth_tokens.create!
    AwardBadgeJob.perform_later(user, :member)
    Metric::Queue.(:sign_up, user.created_at, user:)

    link_courses!
  end

  private
  # Captured once, at signup. The locale someone is demonstrably browsing in
  # (a locale-prefixed page) is an explicit signal and wins; otherwise we fall
  # back to what their browser asks for. A naked URL is not a signal: English
  # is what every unprefixed page serves, so it says nothing about them.
  def set_locale!
    return if user.data.locale.present?

    chosen = path_locale || Locale::FromAcceptLanguage.(accept_language)
    return if chosen.blank?

    user.data.update_column(:locale, chosen.to_s)
  end

  def path_locale
    normalized = Locale::Normalize.(locale)
    normalized unless normalized.nil? || normalized == I18n.default_locale
  end

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
