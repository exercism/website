class DonationsMailer < ApplicationMailer
  def payment_created
    payment = params[:payment]
    @user = payment.user

    @unsubscribe_key = :email_on_donations_payment
    subject = "Thank you for your donation"
    @title = "Thank you so much!"
    mail_to_user(@user, subject)
  end
end
