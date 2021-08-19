class DeviseMailer < Devise::Mailer
  def reset_password_instructions(user, token, options = {})
    @user = user
    @token = token
    @title = "Reset your Exercism password"
    options[:subject] = "[Exercism] Reset password request"
    super
  end

  def confirmation_instructions(user, token, options = {})
    @user = user
    @token = token
    @title = "Confirm your new Exercism account"
    options[:subject] = "[Exercism] Confirm your account"
    super
  end

  def email_changed(user, options = {})
    @user = user
    @title = "Your email address is being changed"
    options[:subject] = "[Exercism] Your email address is being changed"
    super
  end

  def password_change(user, options = {})
    @user = user
    @title = "Your password has been changed"
    options[:subject] = "[Exercism] Your password has been changed"
    super
  end
end
