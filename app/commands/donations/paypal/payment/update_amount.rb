class Donations::Paypal::Payment::UpdateAmount
  include Mandate

  initialize_with :id, :amount

  def call = Donations::Payment::UpdateAmount.(:paypal, id, amount_in_cents)

  private
  def amount_in_cents = (amount * 100).to_i
end
