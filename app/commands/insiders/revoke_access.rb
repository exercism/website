class Insiders::RevokeAccess
  include Mandate

  initialize_with :user

  def call
    return if user.insiders_status == :lifetime_active
    return if user.insiders_status == :ineligible
    return if user.insiders_status == :expired

    new_insiders_status = user.insiders_status == :active ? :expired : :ineligible
    user.update(insiders_status: new_insiders_status)
  end
end
