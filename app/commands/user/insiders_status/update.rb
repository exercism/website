class User::InsidersStatus::Update
  include Mandate

  queue_as :default

  initialize_with :user, :status_before_unset

  def call
    return unless user.insiders_status == :unset

    user.with_lock do
      case User::InsidersStatus::DetermineEligibilityStatus.(user)
      when :eligible_lifetime
        update_eligible_lifetime
      when :eligible
        update_eligible
      when :ineligible
        update_ineligible
      end
    end
  end

  private
  def update_eligible_lifetime
    case status_before_unset
    when :active_lifetime
      user.update(insiders_status: :active_lifetime)
    when :active
      user.update(insiders_status: :active_lifetime)
      User::Notification::Create.(user, :joined_lifetime_insiders)
    else
      user.update(insiders_status: :eligible_lifetime)
      User::Notification::Create.(user, :join_lifetime_insiders) unless status_before_unset == :eligible_lifetime
    end
  end

  def update_eligible
    case status_before_unset
    when :active_lifetime
      user.update(insiders_status: :active_lifetime)
    when :eligible_lifetime
      user.update(insiders_status: :eligible_lifetime)
    when :active
      user.update(insiders_status: :active)
    else
      user.update(insiders_status: :eligible)
      User::Notification::Create.(user, :join_insiders) unless status_before_unset == :eligible
    end
  end

  def update_ineligible
    case status_before_unset
    when :active_lifetime
      user.update(insiders_status: :active_lifetime)
    when :eligible_lifetime
      user.update(insiders_status: :eligible_lifetime)
    else
      user.update(insiders_status: :ineligible)
      User::Notification::Create.(user, :expired_insiders) if status_before_unset == :active
    end
  end
end
