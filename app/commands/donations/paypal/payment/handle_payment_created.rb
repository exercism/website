# This responds to a Paypal 'PAYMENTS.PAYMENT.CREATED' webhook event
class Donations::Paypal::Payment::HandlePaymentCreated
  include Mandate

  queue_as :default

  initialize_with :id, :resource

  def call; end
end
