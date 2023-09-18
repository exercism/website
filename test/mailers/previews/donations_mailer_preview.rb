class DonationsMailerPreview < ActionMailer::Preview
  def payment_created
    DonationsMailer.with(
      payment: Payments::Payment.first
    ).payment_created
  end
end
