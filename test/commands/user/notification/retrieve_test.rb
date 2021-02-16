require 'test_helper'

class User::Notification::RetrieveTest < ActiveSupport::TestCase
  test "only retrieves unread notificatons" do
    user = create :user
    unread = create :notification, read_at: nil, user: user
    create :notification, read_at: Time.current, user: user
    create :notification, read_at: nil

    assert_equal [unread], User::Notification::Retrieve.(user)
  end

  test "orders by id" do
    user = create :user

    first = create :notification, user: user
    second = create :notification, user: user
    third = create :notification, user: user

    assert_equal [first, second, third], User::Notification::Retrieve.(user)
  end

  test "pagination works" do
    user = create :user

    25.times { create :notification, user: user }

    notifications = User::Notification::Retrieve.(user, page: 2)
    assert_equal 2, notifications.current_page
    assert_equal 3, notifications.total_pages
    assert_equal 10, notifications.limit_value
    assert_equal 25, notifications.total_count
  end

  test "per_page works" do
    user = create :user

    25.times { create :notification, user: user }

    notifications = User::Notification::Retrieve.(user, page: 2, per_page: 4)
    assert_equal 2, notifications.current_page
    assert_equal 7, notifications.total_pages
    assert_equal 4, notifications.limit_value
    assert_equal 25, notifications.total_count
  end

  test "returns relationship unless paginated" do
    user = create :user
    create :notification, user: user

    notifications = User::Notification::Retrieve.(user, paginated: false)
    assert notifications.is_a?(ActiveRecord::Relation)
    refute_respond_to notifications, :current_page
  end
end
