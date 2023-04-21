# This responds to a Paypal 'PAYMENT.SALE.REFUNDED' webhook event
class Donations::Paypal::Payment::HandleSaleRefunded
  include Mandate

  initialize_with :resource

  def call; end
end
