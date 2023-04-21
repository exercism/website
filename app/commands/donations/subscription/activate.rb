class Donations::Subscription::Activate
  include Mandate

  initialize_with :subscription

  def call = subscription.update!(status: :active)
end
