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
        create :concept_exercise, track: track
        create :user_code_contribution_reputation_token, user: user, seen: false

        use_capybara_host do
          sign_in!(user)
          visit reputation_journey_path
          click_on "Mark all as seen"
          within(".m-generic-confirmation") { click_on "Continue" }

          # On this page, we don't have a way to know whether all notifications are marked as unseen.
          # I just checked the reputation button on the top bar instead.
          assert_no_css ".--notification.unseen"
        end
      end
    end
  end
end
