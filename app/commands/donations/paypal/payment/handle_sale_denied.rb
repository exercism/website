# This responds to a Paypal 'PAYMENT.SALE.DENIED' webhook event
class Donations::Paypal::Payment::HandleSaleDenied
  include Mandate

  initialize_with :resource

  def call; end
end
