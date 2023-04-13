class User::InsidersStatus::TriggerUpdate
  include Mandate

  initialize_with :user

  def call
    user.with_lock do
      return if %i[active active_lifetime].include?(user.insiders_status)

      status_before_unset = user.insiders_status
      user.update(insiders_status: :unset) if status_before_unset == :ineligible
      User::InsidersStatus::Update.defer(user, status_before_unset)
    end
  end
end
