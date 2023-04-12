class User::InsidersStatus::Activate
  include Mandate

  initialize_with :user

  def call
    return unless %i[eligible eligible_lifetime].include?(user.insiders_status)

    if user.insiders_status == :eligible
      user.update(insiders_status: :active)
      User::Notification::Create.(user, :joined_insiders)
    else
      user.update(insiders_status: :lifetime_active)
      User::Notification::Create.(user, :joined_lifetime_insiders)
    end
  end
end
