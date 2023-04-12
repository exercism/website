class User::InsidersStatus::TriggerUpdate
  include Mandate

  initialize_with :user

  def call
    return if %i[active active_lifetime].include?(user.insiders_status)

    user.update(insiders_status: :unset)
    User::InsidersStatus::Update.defer(user)
  end
end
