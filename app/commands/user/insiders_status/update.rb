class User::InsidersStatus::Update
  include Mandate

  queue_as :default

  initialize_with :user, :status_before_unset

  def call
    eligibility_status = User::InsidersStatus::DetermineEligibilityStatus.(user)
    return if eligibility_status == status_before_unset

    user.with_lock do
      case eligibility_status
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
    return if status_before_unset == :active_lifetime

    if status_before_unset == :active
      user.update(insiders_status: :active_lifetime)
    else
      user.update(insiders_status: :eligible_lifetime)
    end
  end

  def update_eligible
    return if status_before_unset == :active_lifetime
    return if status_before_unset == :active

    user.update(insiders_status: :eligible)
  end

  def update_ineligible
    return if status_before_unset == :active_lifetime
    return if status_before_unset == :eligible_lifetime

    user.update(insiders_status: :ineligible)
  end
end
