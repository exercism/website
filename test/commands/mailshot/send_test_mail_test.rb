require 'test_helper'

class Mailshot::SendTestMailTest < ActiveSupport::TestCase
  test "sends to ihid" do
    ihid = create :user, id: User::IHID_USER_ID
    mailshot = create :mailshot

    User::Mailshot::Send.expects(:call).with(ihid, mailshot)

    Mailshot::SendTestMail.(mailshot)
  end

  test "deletes any old records" do
    ihid = create :user, id: User::IHID_USER_ID
    mailshot = create :mailshot
    User::Mailshot::Send.stubs(:call)

    create(:user_mailshot, user: ihid, mailshot:)
    assert_equal 1, User::Mailshot.count

    Mailshot::SendTestMail.(mailshot)

    assert_equal 0, User::Mailshot.count
  end

  test "updates record" do
    create :user, id: User::IHID_USER_ID
    mailshot = create :mailshot
    refute mailshot.test_sent?

    Mailshot::SendTestMail.(mailshot)

    assert mailshot.test_sent?
  end
end
