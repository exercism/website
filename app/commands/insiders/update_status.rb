class Insiders::UpdateStatus
  include Mandate

  initialize_with :user

  def call = user.update(insiders_status:)

  def insiders_status
    return :lifetime_active if user.insiders_status == :lifetime_active
    return :expired if ineligible? && %i[active expired].include?(user.insiders_status)
    return :ineligible if ineligible?
    return :eligible if eligible? && %i[ineligible eligible].include?(user.insiders_status)

    :active
  end

  memoize
  def eligible? = User::CheckInsidersStatus.(user)
  def ineligible? = !eligible?
end
