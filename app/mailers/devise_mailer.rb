class DeviseMailer < Devise::Mailer
  SUBJECT_PREFIX = "[Exercism]".freeze

  def reset_password_instructions(user, token, options = {})
    @user = user
    @token = token
    @title = t("devise.mailer.reset_password_instructions.title")
    options[:subject] = prefixed_subject("reset_password_instructions")
    super
  end

  def confirmation_instructions(user, token, options = {})
    @user = user
    @token = token
    @title = t("devise.mailer.confirmation_instructions.title")
    options[:subject] = prefixed_subject("confirmation_instructions")
    super
  end

  def email_changed(user, options = {})
    @user = user
    @title = t("devise.mailer.email_changed.title")
    options[:subject] = prefixed_subject("email_changed")
    super
  end

  def password_change(user, options = {})
    @user = user
    @title = t("devise.mailer.password_change.title")
    options[:subject] = prefixed_subject("password_change")
    super
  end

  private
  def prefixed_subject(action) = "#{SUBJECT_PREFIX} #{t("devise.mailer.#{action}.subject")}"
end
