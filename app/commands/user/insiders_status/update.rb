class User::InsidersStatus::Update
  include Mandate

  queue_as :default

  initialize_with :user

  def call
    # Lifetime statuses would not change
    return if user.insiders_status_active_lifetime?
    return if user.insiders_status_eligible_lifetime?

    new_status = User::InsidersStatus::DetermineEligibilityStatus.(user)
    return if new_status == user.insiders_status

    user.with_lock do
      case new_status
      when :eligible_lifetime
        update_eligible_lifetime
      when :eligible
        update_eligible
      when :ineligible
        update_ineligible
      end
    end

    User::InsidersStatus::UpdateFlair.(user) if user.insiders_status_active_lifetime?
    User::SetDiscordRoles.defer(user)
    User::SetDiscourseGroups.defer(user)
    User::Notification::CreateEmailOnly.defer(user, @notification_key) if @notification_key
    AwardBadgeJob.perform_later(user, :lifetime_insider) if user.insiders_status_active_lifetime?
  end

  private
  def update_eligible_lifetime
    case user.insiders_status
    when :active
      @notification_key = :upgraded_to_lifetime_insiders
      user.update(insiders_status: :active_lifetime)
    else
      @notification_key = :eligible_for_lifetime_insiders
      user.update(insiders_status: :eligible_lifetime)
    end
  end

  def update_eligible
    return if user.insiders_status_active?

    @notification_key = :eligible_for_insiders
    user.update(insiders_status: :eligible)
  end

  def update_ineligible
    @notification_key = :expired_insiders if user.insiders_status_active?
    user.update(insiders_status: :ineligible)
  end
end
