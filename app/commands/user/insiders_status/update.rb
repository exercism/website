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
        update_to_eligible_lifetime
      when :eligible
        update_to_eligible
      when :ineligible
        update_to_ineligible
      end
    end

    # ##
    # Note: This code is not called when they GAIN Insiders.
    # Look at Activate.() for that instead.
    # ##

    # Create whatever notification we've generated
    User::Notification::CreateEmailOnly.defer(user, @notification_key) if @notification_key

    if user.insiders_status_ineligible?
      # If someone is no longer eligible, we need to revert
      # a load of bits
      User::SetDiscordRoles.defer(user)
      User::SetDiscourseGroups.defer(user)
      User::Premium::Update.defer(user)
      User::UpdateFlair.defer(user)

    elsif user.insiders_status_active_lifetime?
      # This is only called when someone is changing from
      # normal insider to lifetime insider.
      User::UpdateFlair.defer(user)
      AwardBadgeJob.perform_later(user, :lifetime_insider)
    end
  end

  private
  def update_to_eligible_lifetime
    case user.insiders_status
    when :active
      @notification_key = :upgraded_to_lifetime_insiders
      user.update!(insiders_status: :active_lifetime)
    else
      @notification_key = :eligible_for_lifetime_insiders
      user.update!(insiders_status: :eligible_lifetime)
    end
  end

  def update_to_eligible
    return if user.insiders_status_active?

    @notification_key = :eligible_for_insiders
    user.update!(insiders_status: :eligible)
  end

  def update_to_ineligible
    user.update!(insiders_status: :ineligible)
  end
end
