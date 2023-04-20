# This responds to a Paypal 'PAYMENT.SALE.DENIED' webhook event
class Donations::Paypal::Payment::HandleSaleDenied
  include Mandate

  queue_as :default

  initialize_with :id, :resource

  def call; end
end
