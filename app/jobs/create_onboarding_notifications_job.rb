class CreateOnboardingNotificationsJob < ApplicationJob
  queue_as :background

  OnboardingEmail = Struct.new(:day, :slug, keyword_init: true) do
    extend Mandate::Memoize

    def notification_type
      "onboarding_#{slug}".to_sym
    end

    memoize
    def has_notification?
      text = I18n.backend.send(:translations)[:en][:notifications][notification_type][1]
      text.present?
    end
  end

  # 0 would be immediately after signing up
  # 1 is a day after signing up, etc
  #
  # Each slug should be paired with a User::Notifications::Onboarding{$SLUG}Notification class
  EMAILS = {
    1 => :product,
    3 => :community,
    5 => :insiders
  }.map { |day, slug| OnboardingEmail.new(day:, slug:) }.freeze

  # For each email we get all the users that signed up between
  # n days ago and n+SAFETY_OFFSET_IN_DAYS days ago.
  # So for example, for a day 3 email, if SAFETY_OFFSET_IN_DAYS is 1,
  # we check anyone that signed up between days 3 and 4.
  #
  # This gives us a security blanket that if our scripts don't
  # run for a period of time, no-one gets missed. But after the safety
  # period we don't end up spamming old users. All onboarding notifications
  # only send once, so this is safe to run multiple times.
  SAFETY_OFFSET_IN_DAYS = 1

  private_constant :EMAILS, :SAFETY_OFFSET_IN_DAYS, :OnboardingEmail

  def perform
    I18n.backend.send(:init_translations)

    EMAILS.each do |email|
      users = User.where('created_at < ?', Time.current - email.day.days).
        where('created_at > ?', Time.current - (email.day + SAFETY_OFFSET_IN_DAYS).days)

      users.find_each do |user|
        send_email(user, email)
      rescue StandardError => e
        Bugsnag.notify(e)
      end
    end
  end

  private
  def send_email(user, email)
    if email.has_notification?
      User::Notification::Create.(user, email.notification_type)
    else
      User::Notification::CreateEmailOnly.(user, email.notification_type)
    end
  end
end
