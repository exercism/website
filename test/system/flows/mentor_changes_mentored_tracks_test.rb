require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/websockets_helpers"

module Flows
  class MentorChangesMentoredTracksTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user changes mentored tracks" do
      ruby = create :track, title: "Ruby", slug: "ruby"
      create :track, title: "C#", slug: "csharp"
      mentor = create :user
      create :user_track_mentorship, track: ruby, user: mentor

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_dashboard_path
        click_on "Change tracks"
        find("label", text: "Ruby").click(x: 0, y: 0)
        find("label", text: "C#").click
        click_on "Continue"

        assert_text "C#"
        assert_no_text "Ruby"
      end
    end
  end
end
