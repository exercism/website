require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flow
  module Journey
    class ReputationTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include ActionView::Helpers::SanitizeHelper

      test "shows contribution" do
        user = create :user
        track = create :track, title: "Ruby"
        create(:concept_exercise, track:)
        create :user_code_contribution_reputation_token, user:, seen: false
        create :user_code_contribution_reputation_token, user:, seen: false

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path
          click_on "Mark all as seen"
          within(".m-generic-confirmation") { click_on "Continue" }

          assert_no_css ".--notification.unseen"
          assert_button "Mark all as seen", disabled: true
        end
      end
    end
  end
end
