require 'test_helper'

class User::Notifications::MarkRelevantAsReadTest < ActiveSupport::TestCase
  test "clears correct notifications" do
    user = create :user
    discussion = create(:mentor_discussion)
    discussion_post_1 = create(:mentor_discussion_post, discussion:)
    discussion_post_2 = create(:mentor_discussion_post, discussion:)
    relevant_1 = create :mentor_started_discussion_notification, status: :pending, user:,
      params: { discussion: }
    relevant_2 = create :mentor_replied_to_discussion_notification, status: :pending, user:,
      params: { discussion_post: discussion_post_1 }
    relevant_3 = create :mentor_replied_to_discussion_notification, status: :pending, user:,
      params: { discussion_post: discussion_post_2 }
    irrelevant_1 = create :mentor_started_discussion_notification, status: :pending, params: { discussion: }
    irrelevant_2 = create(:mentor_started_discussion_notification, status: :pending, user:)
    irrelevant_3 = create(:mentor_replied_to_discussion_notification, status: :pending, user:)
    irrelevant_4 = create :mentor_replied_to_discussion_notification, status: :pending,
      params: { discussion_post: discussion_post_2 }

    User::Notification::MarkRelevantAsRead.(user, relevant_1.path)

    assert_equal [relevant_1, relevant_2, relevant_3], User::Notification.read
    assert_equal [irrelevant_1, irrelevant_2, irrelevant_3, irrelevant_4], User::Notification.pending
  end

  test "broadcasts message" do
    user = create :user
    discussion = create(:mentor_discussion)
    notification = create :mentor_started_discussion_notification, status: :pending, user:,
      params: { discussion: }

    NotificationsChannel.expects(:broadcast_changed!).with(user)

    User::Notification::MarkRelevantAsRead.(user, notification.path)
  end

  test "does not broadcast if none were changed" do
    user = create :user
    discussion = create(:mentor_discussion)
    notification = create :mentor_started_discussion_notification, status: :read, user:,
      params: { discussion: }

    NotificationsChannel.expects(:broadcast_changed!).never

    User::Notification::MarkRelevantAsRead.(user, notification.path)
  end
end
