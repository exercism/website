class Payments::Subscription::Overdue
  include Mandate

  initialize_with :subscription

  def call = Payments::Subscription::UpdateStatus.(subscription, :overdue)
end
