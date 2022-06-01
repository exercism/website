require 'test_helper'

class User::Notifications::CreateTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  test "create db record" do
    user = create :user
    type = :mentor_started_discussion
    discussion = create(:mentor_discussion)
    params = { discussion: }

    notification = User::Notification::Create.(user, type, params)

    assert_equal 1, User::Notification.count
    assert notification.pending?
    assert_equal user, notification.user
    assert_equal User::Notifications::MentorStartedDiscussionNotification, notification.class
    assert_equal 1, notification.version
    assert_equal "#{user.id}|mentor_started_discussion|Discussion##{discussion.id}", notification.uniqueness_key

    assert_equal(
      { discussion: discussion.to_global_id.to_s }.with_indifferent_access,
      notification.send(:params)
    )
  end

  test "schedule activation" do
    freeze_time do
      user = create :user
      type = :mentor_started_discussion
      discussion = create(:mentor_discussion)
      params = { discussion: }

      assert_enqueued_with job: ActivateUserNotificationJob, at: Time.current + 5.seconds do
        User::Notification::Create.(user, type, params)
      end
    end
  end

  test "broadcasts message" do
    user = create :user
    type = :mentor_started_discussion
    discussion = create(:mentor_discussion)
    params = { discussion: }
    NotificationsChannel.expects(:broadcast_pending!).with do |u, n|
      assert_equal u, user
      assert n.is_a?(User::Notification)
    end

    User::Notification::Create.(user, type, params)
  end

  test "copes with duplicates" do
    user = create :user
    type = :mentor_started_discussion
    discussion = create(:mentor_discussion)
    params = { discussion: }

    n_1 = User::Notification::Create.(user, type, params)
    n_2 = User::Notification::Create.(user, type, params)
    assert_equal n_1, n_2
  end
end
