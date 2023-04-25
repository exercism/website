class User::InsidersStatus::TriggerUpdate
  include Mandate

  initialize_with :user

  def call
    user.with_lock do
      return if user.insiders_status_active?
      return if user.insiders_status_active_lifetime?

      user.update(insiders_status: :unset) if user.insiders_status_ineligible?
      User::InsidersStatus::Update.defer(user)
    end
  end
end
