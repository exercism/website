# This responds to a Paypal 'PAYMENT.SALE.DENIED' webhook event
class Donations::Paypal::Payment::HandleSaleDenied
  include Mandate

  initialize_with :resource

  def call
    payment = Donations::Payment.find_by(external_id: resource[:parent_payment], provider: :paypal)
    return unless payment

    # TODO: what to do here?
  end
end
