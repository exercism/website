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
    end
  end
end
