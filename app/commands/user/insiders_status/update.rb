class User::InsidersStatus::Update
  include Mandate

  queue_as :default

  initialize_with :user, :status_before_unset

  def call
    case User::InsidersStatus::DetermineEligibilityStatus.(user)
    when :eligible_lifetime
      update_eligible_lifetime
    when :eligible
      update_eligible
    when :ineligible
      update_ineligible
    end
  end

  private
  def update_eligible_lifetime
    case status_before_unset
    when :active_lifetime
      update_insiders_status(:active_lifetime)
    when :active
      update_insiders_status(:active_lifetime)
      User::Notification::Create.(user, :joined_lifetime_insiders) if FeatureFlag::INSIDERS
    else
      update_insiders_status(:eligible_lifetime)
      User::Notification::Create.(user, :join_lifetime_insiders) if FeatureFlag::INSIDERS && status_before_unset != :eligible_lifetime
    end
  end

  def update_eligible
    case status_before_unset
    when :active_lifetime
      update_insiders_status(:active_lifetime)
    when :eligible_lifetime
      update_insiders_status(:eligible_lifetime)
    when :active
      update_insiders_status(:active)
    else
      update_insiders_status(:eligible)
      User::Notification::Create.(user, :join_insiders) if FeatureFlag::INSIDERS && status_before_unset != :eligible
    end
  end

  def update_ineligible
    case status_before_unset
    when :active_lifetime
      update_insiders_status(:active_lifetime)
    when :eligible_lifetime
      update_insiders_status(:eligible_lifetime)
    else
      update_insiders_status(:ineligible)
      User::Notification::Create.(user, :expired_insiders) if FeatureFlag::INSIDERS && status_before_unset == :active
    end
  end

  def update_insiders_status(insiders_status)
    user.with_lock do
      user.update(insiders_status:)
    end
  end
end
