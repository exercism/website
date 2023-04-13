class User::InsidersStatus::Update
  include Mandate

  queue_as :default

  initialize_with :user

  def call
    eligibility_status = User::InsidersStatus::DetermineEligibilityStatus.(user)

    user.with_lock do
      return if eligibility_status == user.insiders_status

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
    return if user.insiders_status == :active_lifetime

    if user.insiders_status == :active
      user.update(insiders_status: :active_lifetime)
    else
      user.update(insiders_status: :eligible_lifetime)
    end
  end

  def update_eligible
    return if user.insiders_status == :active_lifetime
    return if user.insiders_status == :active

    user.update(insiders_status: :eligible)
  end

  def update_ineligible
    return if user.insiders_status == :active_lifetime

    user.update(insiders_status: :ineligible)
  end
end
