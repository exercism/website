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
        discussion = create(:mentor_discussion, mentor:)
        create :mentor_started_discussion_notification, user:, params: { discussion: }, status: :unread

        use_capybara_host do
          sign_in!(user)
          visit notifications_path

          assert_text "mr-mentor has started mentoring your solution to Bob in Ruby"
        end
      end

      test "user views paginated notifications" do
        user = create :user
        create :mentor_started_discussion_notification, user:, status: :unread
        create :student_replied_to_discussion_notification, user:, status: :read

        use_capybara_host do
          sign_in!(user)
          visit notifications_path(per_page: 1)
          assert_text "has added a new comment"
          assert_no_text "has started mentoring"

          click_on "Next", exact: true

          assert_no_text "has added a new comment"
          assert_text "has started mentoring"
        end
      end

      test "user marks notifications as read" do
        user = create :user
        unread = create :student_replied_to_discussion_notification, user:, status: :unread
        read = create :mentor_started_discussion_notification, user:, status: :unread

        use_capybara_host do
          sign_in!(user)
          visit notifications_path
          find("label", class: "notification-cb-#{unread.uuid}").click
          find("label", class: "notification-cb-#{read.uuid}").click
          click_on "Mark as read"

          assert_field "notification-cb-#{unread.uuid}", disabled: false, visible: false
          assert_no_css ".unread"

          assert_no_checked_field "notification-cb-#{unread.uuid}", visible: false
          assert_no_checked_field "notification-cb-#{read.uuid}", visible: false
        end
      end

      test "marked notifications are persisted even when switching pages" do
        user = create :user
        create :mentor_started_discussion_notification, user:, status: :read
        create :student_replied_to_discussion_notification, user:, status: :unread

        use_capybara_host do
          sign_in!(user)
          visit notifications_path(per_page: 1)

          # Click a label
          refute_checked_field nil, visible: false
          within('.notification-row') do
            find("label").click
          end
          assert_checked_field nil, visible: false

          # Change pages
          click_on "Next"
          click_on "Previous"

          # Assert it's still checked
          assert_checked_field nil, visible: false
        end
      end

      test "user marks all notifications as read" do
        user = create :user
        create :mentor_started_discussion_notification, user:, status: :unread
        create :student_replied_to_discussion_notification, user:, status: :unread

        use_capybara_host do
          sign_in!(user)
          visit notifications_path
          click_on "Mark all as read"

          within(".m-generic-confirmation") { click_on "Continue" }

          assert_no_css ".unread"

          assert_button "Mark all as read", disabled: true
        end
      end

      test "user marks notifications as unread" do
        user = create :user
        comment = create :mentor_started_discussion_notification, user:, status: :read
        started = create :student_replied_to_discussion_notification, user:, status: :read

        use_capybara_host do
          sign_in!(user)
          visit notifications_path
          find("label", class: "notification-cb-#{comment.uuid}").click
          find("label", class: "notification-cb-#{started.uuid}").click
          click_on "Mark as unread"

          assert_field "notification-cb-#{comment.uuid}", disabled: false, visible: false
          assert_no_css ".read"

          assert_no_checked_field "notification-cb-#{comment.uuid}", visible: false
          assert_no_checked_field "notification-cb-#{started.uuid}", visible: false
        end
      end

      test "buttons are disabled based on status" do
        user = create :user
        comment = create :mentor_started_discussion_notification, user:, status: :unread
        started = create :student_replied_to_discussion_notification, user:, status: :read

        use_capybara_host do
          sign_in!(user)
          visit notifications_path

          # Selecting only unread
          find("label", class: "notification-cb-#{comment.uuid}").click

          assert_button "Mark as read", disabled: false
          assert_button "Mark as unread", disabled: true

          find("label", class: "notification-cb-#{comment.uuid}").click

          # Selecting only read
          find("label", class: "notification-cb-#{started.uuid}").click

          assert_button "Mark as read", disabled: true
          assert_button "Mark as unread", disabled: false

          find("label", class: "notification-cb-#{started.uuid}").click

          # Selecting both unread and read
          find("label", class: "notification-cb-#{started.uuid}").click
          find("label", class: "notification-cb-#{comment.uuid}").click

          assert_button "Mark as read", disabled: false
          assert_button "Mark as unread", disabled: false
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
