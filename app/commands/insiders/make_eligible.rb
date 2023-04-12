class Insiders::MakeEligible
  include Mandate

  initialize_with :user

  def call
    return if user.insiders_status == :lifetime_active
    return if user.insiders_status == :active

    user.update(insiders_status: :eligible)
  end
end
