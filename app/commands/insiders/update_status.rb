class Insiders::UpdateStatus
  include Mandate

  initialize_with :user

  def call
    if User::CheckInsidersStatus.(user)
      Insiders::MakeEligible.(user)
    else
      Insiders::RevokeAccess.(user)
    end
  end
end
