# This responds to a Paypal 'PAYMENT.SALE.REVERSED' webhook event
class Donations::Paypal::Payment::HandleSaleReversed
  include Mandate

  queue_as :default

  initialize_with :id, :resource

  def call; end
end
