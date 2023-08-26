require "test_helper"

class MailshotsMailerTest < ActionMailer::TestCase
  test "launch_trophies: 1 trophy" do
    user = create :user
    create(:user_track_acquired_trophy, user:)

    email = MailshotsMailer.with(user:).launch_trophies
    subject = "You have a new Track Trophy at Exercism"
    assert_email(email, user.email, subject, "launch_trophies")
  end
end
