require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Common
    class AnnouncementBarTest < ApplicationSystemTestCase
      test "renders announcement bar" do
        use_capybara_host do
          sign_in!
          visit dashboard_path
          click_on "We just launched Exercism V3!"

          within(".m-announcement") { assert_text "Announcement!" }
        end
      end
    end
  end
end
