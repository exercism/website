# This responds to a Paypal 'PAYMENT.SALE.COMPLETED' webhook event
class Donations::Paypal::Payment::HandleSaleCompleted
  include Mandate

  initialize_with :resource

  def call; end
end
