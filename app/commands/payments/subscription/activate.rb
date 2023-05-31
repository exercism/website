class Payments::Subscription::Activate
  include Mandate

  initialize_with :subscription

  def call = Payments::Subscription::UpdateStatus.(subscription, :active)
end
