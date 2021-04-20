require 'test_helper'

class User::Notification::RetrieveTest < ActiveSupport::TestCase
  test "retrieves unread notifications first" do
    user = create :user
    unread_1 = create :notification, status: :unread, user: user
    read_1 = create :notification, status: :read, user: user
    read_2 = create :notification, status: :read, user: user
    unread_2 = create :notification, status: :unread, user: user

    # Pending
    create :notification, status: :pending, user: user

    # Someone else's
    create :notification, status: :unread

    assert_equal [unread_2, unread_1, read_2, read_1], User::Notification::Retrieve.(user)
  end

  test "orders by recent first (id desc)" do
    user = create :user

    first = create :notification, user: user, status: :unread
    second = create :notification, user: user, status: :unread
    third = create :notification, user: user, status: :unread

    assert_equal [third, second, first], User::Notification::Retrieve.(user)
  end

  test "pagination works" do
    user = create :user

    7.times { create :notification, user: user, status: :unread }

    notifications = User::Notification::Retrieve.(user, page: 2)
    assert_equal 2, notifications.current_page
    assert_equal 2, notifications.total_pages
    assert_equal 5, notifications.limit_value
    assert_equal 7, notifications.total_count
  end

  test "per_page works" do
    user = create :user

    7.times { create :notification, user: user, status: :unread }

    notifications = User::Notification::Retrieve.(user, page: 2, per_page: 3)
    assert_equal 2, notifications.current_page
    assert_equal 3, notifications.total_pages
    assert_equal 3, notifications.limit_value
    assert_equal 7, notifications.total_count
  end

  test "returns relationship unless paginated" do
    user = create :user
    create :notification, user: user

    notifications = User::Notification::Retrieve.(user, paginated: false)
    assert notifications.is_a?(ActiveRecord::Relation)
    refute_respond_to notifications, :current_page
  end
end
