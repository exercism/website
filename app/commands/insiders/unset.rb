class Insiders::Unset
  include Mandate

  initialize_with :user

  def call
    user.update(insiders_status: :unset)
    Insiders::UpdateStatus.defer(self)
  end
end
