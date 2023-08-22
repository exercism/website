class User::InsidersStatus::Activate
  include Mandate

  initialize_with :user, recalculate_status: false

  def call
    status = recalculate_status ?
      User::InsidersStatus::DetermineEligibilityStatus.(user) :
      user.insiders_status

    return unless %i[eligible eligible_lifetime].include?(status)

    user.with_lock do
      if status == :eligible_lifetime
        @notification_key = :joined_lifetime_insiders
        user.update!(insiders_status: :active_lifetime)
      else
        @notification_key = :joined_insiders
        user.update!(insiders_status: :active)
      end
    end

    User::UpdateFlair.(user)
    User::Notification::CreateEmailOnly.defer(user, @notification_key)
    AwardBadgeJob.perform_later(user, :insider)
    AwardBadgeJob.perform_later(user, :lifetime_insider) if user.insiders_status_active_lifetime?
    User::SetDiscordRoles.defer(user)
    User::SetDiscourseGroups.defer(user)
  end
end
