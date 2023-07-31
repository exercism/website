require 'test_helper'

class User::Notification::RetrieveTest < ActiveSupport::TestCase
  test "orders correctly" do
    user = create :user
    unread_1 = create(:notification, status: :unread, user:)
    read_1 = create(:notification, status: :read, user:)
    read_2 = create(:notification, status: :read, user:)
    unread_2 = create(:notification, status: :unread, user:)

    # Pending
    create(:notification, status: :pending, user:)

    # Someone else's
    create :notification, status: :unread

    assert_equal [unread_2, read_2, read_1, unread_1], User::Notification::Retrieve.(user)
    assert_equal [unread_2, read_2, read_1, unread_1], User::Notification::Retrieve.(user, order: nil)
    assert_equal [unread_2, read_2, read_1, unread_1], User::Notification::Retrieve.(user, order: 'foobar')
    assert_equal [unread_2, unread_1, read_2, read_1], User::Notification::Retrieve.(user, order: 'unread_first')
    assert_equal [unread_2, unread_1, read_2, read_1], User::Notification::Retrieve.(user, order: :unread_first)
  end

  test "pagination works" do
    user = create :user

    7.times { create :notification, user:, status: :unread }

    notifications = User::Notification::Retrieve.(user, page: 2)
    assert_equal 2, notifications.current_page
    assert_equal 2, notifications.total_pages
    assert_equal 5, notifications.limit_value
    assert_equal 7, notifications.total_count
  end

  test "per_page works" do
    user = create :user

    7.times { create :notification, user:, status: :unread }

    notifications = User::Notification::Retrieve.(user, page: 2, per_page: 3)
    assert_equal 2, notifications.current_page
    assert_equal 3, notifications.total_pages
    assert_equal 3, notifications.limit_value
    assert_equal 7, notifications.total_count
  end

  test "returns relationship unless paginated" do
    user = create :user
    create(:notification, user:)

    notifications = User::Notification::Retrieve.(user, paginated: false)
    assert notifications.is_a?(ActiveRecord::Relation)
    refute_respond_to notifications, :current_page
  end
end
