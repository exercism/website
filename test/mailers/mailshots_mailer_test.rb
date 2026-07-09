require "test_helper"

class MailshotsMailerTest < ActionMailer::TestCase
  test "jiki_launch: renders for non-translators" do
    user = create :user

    email = MailshotsMailer.with(user:).jiki_launch
    subject = "Learn to Build in the LLM Era. Meet Jiki."
    assert_email(email, user.email, subject, "jiki_launch", bulk: true)

    refute_includes email.html_part.body.to_s, "You previously signed up to help with translating Exercism"
  end

  test "jiki_launch: shows the translator section for people who signed up to translate" do
    user = create :user
    user.update!(translator_locales: ["fr"])

    email = MailshotsMailer.with(user:).jiki_launch
    subject = "Learn to Build in the LLM Era. Meet Jiki."
    assert_email(email, user.email, subject, "jiki_launch", bulk: true)

    assert_includes email.html_part.body.to_s, "You previously signed up to help with translating Exercism"
  end
end
