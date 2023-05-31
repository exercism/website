class User::InsidersStatus::Activate
  include Mandate

  initialize_with :user, force_lifetime: false

  def call
    return unless force_lifetime || user.insiders_status_eligible? || user.insiders_status_eligible_lifetime?

    user.with_lock do
      if user.insiders_status == :eligible_lifetime || force_lifetime
        @notification_key = :joined_lifetime_insiders
        user.update!(insiders_status: :active_lifetime)
      else
        @notification_key = :joined_insiders
        user.update!(insiders_status: :active)
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
