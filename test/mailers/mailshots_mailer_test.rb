require "test_helper"

class MailshotsMailerTest < ActionMailer::TestCase
  test "launch_trophies: 1 trophy" do
    user = create :user
    create(:user_track_acquired_trophy, user:)

    email = MailshotsMailer.with(user:).launch_trophies
    subject = "You have a new Track Trophy at Exercism"
    assert_email(email, user.email, subject, "launch_trophies", bulk: true)
  end

  test "launch_trophies: 5 trophies" do
    user = create :user
    5.times { create(:user_track_acquired_trophy, user:, track: create(:track, :random_slug)) }

    email = MailshotsMailer.with(user:).launch_trophies
    subject = "You have five new Track Trophies at Exercism"
    assert_email(email, user.email, subject, "launch_trophies", bulk: true)
  end
end
