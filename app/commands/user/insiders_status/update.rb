class User::InsidersStatus::Update
  include Mandate

  queue_as :default

  initialize_with :user

  def call
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

  private
  memoize
  def eligibility_status = User::InsidersStatus::DetermineEligibilityStatus.(user)

  def update_eligible_lifetime
    return if user.insiders_status == :lifetime_active

    user.update(insiders_status: :eligible_lifetime)
  end

  def update_eligible
    return if user.insiders_status == :lifetime_active
    return if user.insiders_status == :active

    user.update(insiders_status: :eligible)
  end

  def update_ineligible
    return if user.insiders_status == :lifetime_active
    return if user.insiders_status == :expired

    if user.insiders_status == :active
      user.update(insiders_status: :expired)
    else
      user.update(insiders_status: :ineligible)
    end
  end
end
