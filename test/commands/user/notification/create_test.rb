require 'test_helper'

class User::Notifications::CreateTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  test "create db record" do
    user = create :user
    type = :mentor_started_discussion
    discussion = create(:solution_mentor_discussion)
    params = { discussion: discussion }

    notification = User::Notification::Create.(user, type, params)

    assert_equal 1, User::Notification.count
    assert_equal user, notification.user
    assert_equal User::Notifications::MentorStartedDiscussionNotification, notification.class
    assert_equal 1, notification.version
    assert_equal "#{user.id}-mentor_started_discussion-Discussion##{discussion.id}", notification.uniqueness_key
    assert_equal params, notification.send(:params)
  end

  test "broadcasts message" do
    user = create :user
    type = :mentor_started_discussion
    discussion = create(:solution_mentor_discussion)
    params = { discussion: discussion }
    NotificationsChannel.expects(:broadcast_changed).with(user)

    User::Notification::Create.(user, type, params)
  end
end
