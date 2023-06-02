class Payments::Paypal::Customer::FindOrUpdate
  include Mandate

  initialize_with :paypal_payer_id, :paypal_payer_email, user_email: nil

  def call
    return user_by_paypal_id if user_by_paypal_id

    user_by_email&.tap do |user|
      user.update!(paypal_payer_id:)
    end
  end

  private
  memoize
  def user_by_paypal_id = User.with_data.find_by(data: { paypal_payer_id: })

  memoize
  def user_by_email = User.find_by(email: user_email) || User.find_by(email: paypal_payer_email)
end
