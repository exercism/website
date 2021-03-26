require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/websockets_helpers"
require_relative "../../../support/markdown_editor_helpers"

module Components
  module Student
    class ExerciseStatusTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include WebsocketsHelpers
      include MarkdownEditorHelpers

      test "shows locked exercise tooltip" do
        user = create :user
        track = create :track
        exercise = create :concept_exercise, track: track, title: "Lasagna"
        exercise.prerequisites << create(:track_concept)
        create :user_track, track: track, user: user

        use_capybara_host do
          sign_in!(user)
          visit track_path(track)
          within(".exercises") { find(".c-ed.--l").hover }
        end

        assert_text "Lasagna"
      end
    end
  end
end
