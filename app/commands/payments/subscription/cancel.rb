class Payments::Subscription::Cancel
  include Mandate

  initialize_with :subscription

  def call = Payments::Subscription::UpdateStatus.(subscription, :canceled)
end
