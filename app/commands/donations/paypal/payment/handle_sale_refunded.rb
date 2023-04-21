# This responds to a Paypal 'PAYMENT.SALE.REFUNDED' webhook event
class Donations::Paypal::Payment::HandleSaleRefunded
  include Mandate

  initialize_with :resource

  def call
    payment = Donations::Payment.find_by(external_id: resource[:parent_payment], provider: :paypal)
    return unless payment

    # TODO: what to do here?
  end
end
