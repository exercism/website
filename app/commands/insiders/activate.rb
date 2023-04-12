class Insiders::Activate
  include Mandate

  initialize_with :user

  def call
    return unless user.insiders_status == :eligible

    user.update(insiders_status: :active)

    User::Notification::Create.(user, :joined_insiders)
  end
end
