class User::InsidersStatus::Activate
  include Mandate

  initialize_with :user

  def call
    return unless user.insiders_status_eligible? || user.insiders_status_eligible_lifetime?

    user.with_lock do
      case user.insiders_status
      when :eligible
        @notification_key = :joined_insiders
        user.update!(insiders_status: :active)
      when :eligible_lifetime
        @notification_key = :joined_lifetime_insiders
        user.update!(insiders_status: :active_lifetime)
      end
    end

    User::UpdateFlair.(user)
    User::Premium::Update.(user)
    User::Notification::CreateEmailOnly.defer(user, @notification_key)
    AwardBadgeJob.perform_later(user, :insider)
    AwardBadgeJob.perform_later(user, :lifetime_insider) if user.insiders_status_active_lifetime?
    User::SetDiscordRoles.defer(user)
    User::SetDiscourseGroups.defer(user)
  end
end
