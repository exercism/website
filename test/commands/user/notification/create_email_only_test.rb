require 'test_helper'

class User::Notifications::CreateEmailOnlyTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  test "create db record" do
    user = create :user
    type = :mentor_started_discussion
    discussion = create(:mentor_discussion)
    params = { discussion: }

    User::Notification::SendEmail.expects(:call).with { |n| assert n.is_a?(User::Notification) }

    notification = User::Notification::CreateEmailOnly.(user, type, **params)

    assert_equal 1, User::Notification.count
    assert notification.email_only?
    assert_equal user, notification.user
    assert_instance_of User::Notifications::MentorStartedDiscussionNotification, notification
    assert_equal 1, notification.version
    assert_equal "#{user.id}|mentor_started_discussion|Discussion##{discussion.id}", notification.uniqueness_key

    assert_equal(
      { discussion: discussion.to_global_id.to_s }.with_indifferent_access,
      notification.send(:params)
    )
  end

  test "copes with duplicates" do
    user = create :user
    type = :mentor_started_discussion
    discussion = create(:mentor_discussion)
    params = { discussion: }

    n_1 = User::Notification::CreateEmailOnly.(user, type, **params)
    n_2 = User::Notification::CreateEmailOnly.(user, type, **params)
    assert_equal n_1, n_2
  end
end
