class User::InsidersStatus::Unset
  include Mandate

  initialize_with :user

  def call
    user.update(insiders_status: :unset)
    User::InsidersStatus::Update.defer(user)
  end
end
