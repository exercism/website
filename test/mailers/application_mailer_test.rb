require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "does not send if user may not receive emails" do
    user = create :user
    user.expects(may_receive_emails?: false)
    notification = create(:joined_exercism_notification, user:)

    NotificationsMailer.with(notification:).joined_exercism.deliver_now

    assert_no_emails
  end

  test "sends email to user when they may receive them" do
    user = create :user
    user.expects(may_receive_emails?: true)
    notification = create(:joined_exercism_notification, user:)

    NotificationsMailer.with(notification:).joined_exercism.deliver_now

    assert_emails 1
  end

  test "correctly sends with transactional credentials" do
    user = create :user
    notification = create(:joined_exercism_notification, user:)

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      ApplicationMailer.any_instance.expects(:mail_to_user).with(
        user, "Welcome to Exercism",
        from: "Exercism <hello@mail.exercism.org>",
        delivery_method_options: {
          user_name: Exercism.secrets.transactional_smtp_username,
          password: Exercism.secrets.transactional_smtp_password,
          address: Exercism.secrets.transactional_smtp_address,
          port: Exercism.secrets.transactional_smtp_port,
          authentication: Exercism.secrets.transactional_smtp_authentication,
          enable_starttls_auto: true
        }
      )
    end
    NotificationsMailer.with(notification:).joined_exercism.deliver_now
  end

  test "correctly sends with bulk credentials" do
    user = create :user
    mailshot = create :mailshot

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      ApplicationMailer.any_instance.expects(:mail_to_user).with(
        user, "Be a badass",
        from: "Jeremy from Exercism <hello@mail.exercism.org>",
        delivery_method_options: {
          user_name: Exercism.secrets.transactional_smtp_username,
          password: Exercism.secrets.transactional_smtp_password,
          address: Exercism.secrets.transactional_smtp_address,
          port: Exercism.secrets.transactional_smtp_port,
          authentication: Exercism.secrets.transactional_smtp_authentication,
          enable_starttls_auto: true
        }
      )
    end
    MailshotsMailer.with(user:, mailshot:).mailshot.deliver_now
  end
end
