# This responds to a Paypal 'PAYMENT.SALE.REFUNDED' webhook event
class Donations::Paypal::Payment::HandleSaleRefunded
  include Mandate

  queue_as :default

  initialize_with :id, :resource

  def call; end
end
