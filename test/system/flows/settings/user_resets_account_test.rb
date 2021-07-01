require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserResetsAccountTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user resets account" do
        url = "https://exercism.tests/README.md"
        PagesController.stubs(:readme_url).returns(url)
        stub_request(:get, url).to_return(status: 200)
        user = create :user, handle: "handle"

        use_capybara_host do
          sign_in!(user)
          visit settings_path

          click_on "Reset account"
          fill_in "To confirm, write your handle handle in the box below:", with: "handle"
          within(".m-reset-account") { click_on "Reset account" }

          assert_text "Welcome to the Exercism v3 Beta"
        end
      end
    end
  end
end
