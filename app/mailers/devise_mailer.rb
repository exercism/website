class DeviseMailer < Devise::Mailer
  def reset_password_instructions(user, token, options = {})
    @user = user
    @token = token
    options[:subject] = "[Exercism] Reset password request"
    super
  end

  def confirmation_instructions(user, token, options = {})
    @user = user
    @token = token
    options[:subject] = "Confirm your Exercism account"
    super
  end
end
