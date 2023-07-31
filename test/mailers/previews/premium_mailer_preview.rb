class PremiumMailerPreview < ActionMailer::Preview
  def payment_created
    PremiumMailer.with(
      payment: Payments::Payment.first
    ).payment_created
  end
end
