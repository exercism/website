class Mailshot::SendTestMail
  include Mandate

  initialize_with :mailshot

  def call
    user = User.find(User::IHID_USER_ID)

    # Delete any old records as there's an db unique index guard here
    # that guarantees the email can ony be sent once.
    User::Mailshot.where(user:, mailshot:).destroy_all

    # Now send the email
    if mailshot.custom_mailer?
      User::Mailshot::SendWithCustomMailer.(user, mailshot)
    else
      User::Mailshot::Send.(user, mailshot)
    end

    mailshot.update!(test_sent: true)
  end
end
