# This responds to a Paypal 'PAYMENTS.PAYMENT.CREATED' webhook event
class Donations::Paypal::Payment::HandlePaymentCreated
  include Mandate

  initialize_with :resource

  def call; end
end
