class DonationsMailer < ApplicationMailer
  def payment_created
    payment = params[:payment]
    @user = payment.user

    # Donation receipts have no communication preference, so they offer no
    # per-email unsubscribe link.
    subject = t(".subject")
    @title = t(".title")
    transactional_mail(@user, subject)
  end
end
