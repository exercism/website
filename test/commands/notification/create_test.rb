require 'test_helper'

class Notification::CreateTest < ActiveSupport::TestCase
  test "create db record" do
    user = create :user
    type = :mentor_discussion_started
    params = {foo: 'bar'}

    notification = Notification::Create.(user, type, params)

    assert_equal 1, Notification.count
    assert_equal user, notification.user
    assert_equal Notification::MentorDiscussionStartedNotification, notification.class
    assert_equal 1, notification.version
    assert_equal params, notification.send(:params)
  end
end
