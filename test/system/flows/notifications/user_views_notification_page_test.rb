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
    end
  end
end
