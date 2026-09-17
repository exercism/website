require "test_helper"

class MailerLocaleTest < ActionMailer::TestCase
  def localise_emails!
    ApplicationMailer.send(:remove_const, :LOCALISE_EMAILS)
    ApplicationMailer.const_set(:LOCALISE_EMAILS, true)
  end

  teardown do
    ApplicationMailer.send(:remove_const, :LOCALISE_EMAILS)
    ApplicationMailer.const_set(:LOCALISE_EMAILS, false)
  end

  def notification_email(user)
    solution = create(:practice_solution, user:)
    discussion = create(:mentor_discussion, solution:)
    notification = create(:mentor_started_discussion_notification, user:, params: { discussion: })
    NotificationsMailer.with(notification:).mentor_started_discussion
  end

  def hungarian_user
    create(:user).tap { |user| user.update!(locale: "hu") }
  end

  test "emails stay english, with english links, while the decision is open" do
    with_served_locales(:hu) do
      body = notification_email(hungarian_user).html_part.body.to_s
      assert_includes body, "https://test.exercism.org/tracks/"
      refute_includes body, "https://test.exercism.org/hu/"
    end
  end

  test "renders in the recipient's locale, with locale-correct links, outside any request" do
    localise_emails!

    with_served_locales(:hu) do
      LocaleRoster.stubs(production: %i[en hu])
      user = hungarian_user
      locales = []
      NotificationsMailer.any_instance.stubs(:setup_advert!).with { locales << I18n.locale }

      body = Thread.new { notification_email(user).html_part.body.to_s }.value

      assert_equal [:hu], locales
      assert_includes body, "https://test.exercism.org/hu/tracks/"
      refute_includes body, %(href="https://test.exercism.org/tracks/)
      assert_equal :en, I18n.locale
    end
  end

  test "english, unknown and unviewable locales get english" do
    localise_emails!

    with_served_locales(:hu) do
      # hu is work in progress, and this user is not one of its translators
      body = notification_email(hungarian_user).html_part.body.to_s
      refute_includes body, "https://test.exercism.org/hu/"

      translator = hungarian_user.tap { |u| u.update!(translator_locales: ["hu"]) }
      assert_includes notification_email(translator).html_part.body.to_s, "https://test.exercism.org/hu/"

      other = create(:user).tap { |u| u.update!(locale: "xx") }
      refute_includes notification_email(other).html_part.body.to_s, "https://test.exercism.org/hu/"
    end
  end

  test "devise emails find their recipient too" do
    localise_emails!

    with_served_locales(:hu) do
      LocaleRoster.stubs(production: %i[en hu])

      email = DeviseMailer.confirmation_instructions(hungarian_user, "token")
      assert_includes email.html_part.body.to_s, "https://test.exercism.org/hu/users/confirmation?confirmation_token=token"
    end
  end

  test "mailshots only exist in english, so they are sent in english" do
    localise_emails!

    with_served_locales(:hu) do
      mailshot = create :mailshot

      user = hungarian_user.tap { |u| u.update!(translator_locales: ["hu"]) }
      email = MailshotsMailer.with(user:, mailshot:).mailshot
      refute_includes email.html_part.body.to_s, "https://test.exercism.org/hu/"
    end
  end
end
