class User::InsidersStatus::TriggerUpdate
  include Mandate

  initialize_with :user

  def call
    user.with_lock do
      return if user.insiders_status_active_lifetime?
      return if user.insiders_status_eligible_lifetime?

      user.update!(insiders_status: :unset) if user.insiders_status_ineligible?
    end

    User::InsidersStatus::Update.defer(user)
  end
end
