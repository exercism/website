# TODO: do we need a separate mailer?
class PremiumMailer < ApplicationMailer
  def payment_created
    payment = params[:payment]
    @user = payment.user

    # TODO: decide which unsubscribe key
    @unsubscribe_key = :email_on_donations_payment
    subject = "Welcome to Exercism Premium!"
    @title = "Thank you so much!"
    mail_to_user(@user, subject)
  end
end
