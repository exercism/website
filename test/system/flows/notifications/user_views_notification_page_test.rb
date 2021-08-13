require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/websockets_helpers"

module Flows
  module Notifications
    class UserViewsNotifictionPageTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include WebsocketsHelpers

      test "user views notifications" do
        user = create :user
        mentor = create :user, handle: "mr-mentor"
        discussion = create :mentor_discussion, mentor: mentor
        create :mentor_started_discussion_notification, user: user, params: { discussion: discussion }, status: :unread

        use_capybara_host do
          sign_in!(user)
          visit notifications_path

          assert_text "mr-mentor has started mentoring your solution to Bob in Ruby"
        end
      end

      test "user views paginated notifications" do
        user = create :user
        create :mentor_started_discussion_notification, user: user, status: :unread
        create :student_replied_to_discussion_notification, user: user, status: :read

        use_capybara_host do
          sign_in!(user)
          visit notifications_path(per_page: 1)
          click_on "2", exact: true

          assert_text "has added a new comment"
          assert_no_text "has started mentoring"
        end
      end

      test "user marks notifications as read" do
        user = create :user
        create :mentor_started_discussion_notification, user: user, status: :unread
        create :student_replied_to_discussion_notification, user: user, status: :unread

        use_capybara_host do
          sign_in!(user)
          visit notifications_path
          find("label", text: "has added a new comment").click
          find("label", text: "has started mentoring").click
          click_on "Mark as read"

          assert_field "has added a new comment", disabled: false, visible: false
          assert_no_css ".unread"

          assert_no_checked_field "has added a new comment", visible: false
          assert_no_checked_field "has started mentoring", visible: false
        end
      end

      test "user marks notifications as unread" do
        user = create :user
        create :mentor_started_discussion_notification, user: user, status: :read
        create :student_replied_to_discussion_notification, user: user, status: :read

        use_capybara_host do
          sign_in!(user)
          visit notifications_path
          find("label", text: "has added a new comment").click
          find("label", text: "has started mentoring").click
          click_on "Mark as unread"

          assert_field "has added a new comment", disabled: false, visible: false
          assert_no_css ".read"

          assert_no_checked_field "has added a new comment", visible: false
          assert_no_checked_field "has started mentoring", visible: false
        end
      end

      test "user views empty state" do
        user = create :user

        use_capybara_host do
          sign_in!(user)
          visit notifications_path

          assert_text "You have no notifications"
        end
      end
    end
  end
end
