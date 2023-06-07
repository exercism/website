class Payments::Paypal::Customer::FindOrUpdate
  include Mandate

  initialize_with :paypal_payer_id, :paypal_payer_email, user_id: nil

  def call
    return user_by_paypal_id if user_by_paypal_id

    user&.tap { |u| u.update!(paypal_payer_id:) }
  end

  private
  memoize
  def user_by_paypal_id = User.with_data.find_by(data: { paypal_payer_id: })

  def user = user_by_id || user_by_email
  def user_by_id = user_id ? User.find_by(id: user_id) : nil
  def user_by_email = User.find_by(email: paypal_payer_email)
end
