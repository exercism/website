class DonationsMailerPreview < ActionMailer::Preview
  def payment_created
    DonationsMailer.with(
      payment: Donations::Payment.first
    ).payment_created
  end
end
