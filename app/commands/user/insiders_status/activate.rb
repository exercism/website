class User::InsidersStatus::Activate
  include Mandate

  initialize_with :user

  def call
    return unless user.insiders_status_eligible? || user.insiders_status_eligible_lifetime?

    user.with_lock do
      case user.insiders_status
      when :eligible
        @notification_key = :joined_insiders
        @flair_key = :insider
        user.update(insiders_status: :active)
      when :eligible_lifetime
        @notification_key = :joined_lifetime_insiders
        @flair_key = :lifetime_insider
        user.update(insiders_status: :active_lifetime)
      end
    end

    user.update(flair: @flair_key) unless %i[founder staff lifetime_insider].include?(user.flair)
    User::Notification::CreateEmailOnly.defer(user, @notification_key)
    AwardBadgeJob.perform_later(user, :insider)
    AwardBadgeJob.perform_later(user, :lifetime_insider) if user.insiders_status_active_lifetime?
    User::SetDiscordRoles.defer(user)
    User::SetDiscourseGroups.defer(user)
  end
end
