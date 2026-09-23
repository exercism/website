require "test_helper"

class MailerLocaleTest < ActionMailer::TestCase
  # rubocop:disable Style/FormatStringToken
  CATALOG = {
    notifications_mailer: {
      mentor_started_discussion: {
        body_markdown: "[Beszélgetés](%{discussion_url})",
        title: "A megoldásodat mentorálják",
        subject: "%{mentor_handle} mentorálni kezdett: %{track_title}/%{exercise_title}"
      }
    },
    devise: {
      mailer: {
        confirmation_instructions: {
          body_markdown: "[Megerősítés](%{confirmation_url})",
          title: "Erősítsd meg az új Exercism-fiókodat",
          subject: "Erősítsd meg a fiókodat"
        }
      }
    }
  }.freeze
  # rubocop:enable Style/FormatStringToken

  def notification_email(user)
    solution = create(:practice_solution, user:)
    discussion = create(:mentor_discussion, solution:)
    notification = create(:mentor_started_discussion_notification, user:, params: { discussion: })
    NotificationsMailer.with(notification:).mentor_started_discussion
  end

  def hungarian_user
    create(:user).tap { |user| user.update!(locale: "hu") }
  end

  test "renders in the recipient's locale, with locale-correct links, outside any request" do
    with_published_translations(hu: { backend: CATALOG }) do
      user = hungarian_user
      locales = []
      NotificationsMailer.any_instance.stubs(:setup_advert!).with { locales << I18n.locale }

      body = Thread.new { notification_email(user).html_part.body.to_s }.value

      assert_equal [:hu], locales
      assert_includes body, %(<html lang="hu">)
      assert_includes body, %(lang="hu" style=)
      assert_includes body, "https://test.exercism.org/hu/tracks/"
      refute_includes body, %(href="https://test.exercism.org/tracks/)
      assert_equal :en, I18n.locale
    end
  end

  test "english and unknown locales get english" do
    with_published_translations(hu: { backend: CATALOG }) do
      other = create(:user).tap { |u| u.update!(locale: "xx") }
      refute_includes notification_email(other).html_part.body.to_s, "https://test.exercism.org/hu/"

      english = create(:user).tap { |u| u.update!(locale: "en") }
      body = notification_email(english).html_part.body.to_s
      refute_includes body, "https://test.exercism.org/hu/"
      assert_includes body, %(<html lang="en">)
    end
  end

  test "devise emails find their recipient too" do
    with_published_translations(hu: { backend: CATALOG }) do
      email = DeviseMailer.confirmation_instructions(hungarian_user, "token")
      assert_includes email.html_part.body.to_s, "https://test.exercism.org/hu/users/confirmation?confirmation_token=token"
    end
  end

  test "notification subjects and titles come from the recipient's locale" do
    with_published_translations(hu: { backend: CATALOG }) do
      email = notification_email(hungarian_user)

      assert_includes email.subject, "mentorálni kezdett:"
      refute_includes email.subject, "has started mentoring"
      assert_includes email.html_part.body.to_s, "A megoldásodat mentorálják"
    end
  end

  test "devise titles translate and the [Exercism] subject prefix stays in english" do
    with_published_translations(hu: { backend: CATALOG }) do
      email = DeviseMailer.confirmation_instructions(hungarian_user, "token")

      assert_equal "[Exercism] Erősítsd meg a fiókodat", email.subject
      assert_includes email.html_part.body.to_s, "Erősítsd meg az új Exercism-fiókodat"
    end
  end

  test "english recipients get the english subject and title" do
    email = DeviseMailer.confirmation_instructions(create(:user), "token")

    assert_equal "[Exercism] Confirm your account", email.subject
    assert_includes email.html_part.body.to_s, "Confirm your new Exercism account"
  end

  test "mailshots only exist in english, so they are sent in english" do
    mailshot = create :mailshot
    email = MailshotsMailer.with(user: hungarian_user, mailshot:).mailshot
    refute_includes email.html_part.body.to_s, "https://test.exercism.org/hu/"
  end
end
