class DonationsMailer < ApplicationMailer
  def payment_created
    payment = params[:payment]
    @user = payment.user

    @unsubscribe_key = :email_on_donations_payment
    subject = t(".subject")
    @title = t(".title")
    transactional_mail(@user, subject)
  end
end
