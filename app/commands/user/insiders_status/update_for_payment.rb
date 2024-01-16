# This handles insider status changes in response to payments.
# As opposed to manual checks or responses to reputation, we want
# these to be immediate, as the user is actively expecting accesss
# to Insiders to happen immediately.

class User::InsidersStatus::UpdateForPayment
  include Mandate

  initialize_with :user

  def call
    if user.insider?
      User::InsidersStatus::Update.(user)
    else
      User::InsidersStatus::Activate.(user, recalculate_status: true)
    end
  end
end
