# This responds to a Paypal 'PAYMENT.SALE.COMPLETED' webhook event
class Donations::Paypal::Payment::HandleSaleCompleted
  include Mandate

  queue_as :default

  initialize_with :id, :resource

  def call; end
end
