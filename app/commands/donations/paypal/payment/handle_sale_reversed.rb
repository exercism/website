# This responds to a Paypal 'PAYMENT.SALE.REVERSED' webhook event
class Donations::Paypal::Payment::HandleSaleReversed
  include Mandate

  initialize_with :resource

  def call; end
end
