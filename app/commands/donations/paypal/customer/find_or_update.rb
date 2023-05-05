class Donations::Paypal::Customer::FindOrUpdate
  include Mandate

  initialize_with :paypal_payer_id, :email

  def call
    paypal_user = User.with_data.find_by(data: { paypal_payer_id: })
    return paypal_user if paypal_user

    User.find_by(email:)&.tap do |user|
      user.update(paypal_payer_id:)
    end
  end
end
