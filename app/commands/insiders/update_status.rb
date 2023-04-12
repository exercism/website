class Insiders::UpdateStatus
  include Mandate

  queue_as :default

  initialize_with :user

  def call
    if User::CheckInsidersStatus.(user)
      Insiders::GrantAccess.(user)
    else
      Insiders::RevokeAccess.(user)
    end
  end
end
