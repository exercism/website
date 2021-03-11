require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/websockets_helpers"

module Flows
  class MentorChangesMentoredTracksTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user changes mentored tracks" do
      ruby = create :track, title: "Ruby", slug: "ruby"
      csharp = create :track, title: "C#", slug: "csharp"
      series = create :concept_exercise, title: "Series", track: csharp
      mentor = create :user
      create :user_track_mentorship, track: ruby, user: mentor
      create :solution_mentor_request, exercise: series

      use_capybara_host do
        sign_in!(mentor)
        visit mentoring_dashboard_path
        click_on "Change tracks"
        find("label.track", text: "Ruby").click
        find("label.track", text: "C#").click
        click_on "Continue"

        assert_text "C#"
        assert_text "on Series"
        assert_no_text "Ruby"
      end
    end
  end
end
