require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"
require_relative "../../../../support/markdown_editor_helpers"

module Components
  module Mentoring
    module Discussion
      class ScratchpadTest < ApplicationSystemTestCase
        include CapybaraHelpers
        include MarkdownEditorHelpers

        test "mentor saves scratchpad page" do
          mentor = create :user, handle: "author"
          solution = create :concept_solution
          discussion = create(:mentor_discussion, solution:, mentor:)
          create(:iteration, solution:)

          use_capybara_host do
            sign_in!(mentor)
            visit mentoring_discussion_path(discussion)
            click_on "Scratchpad"
            fill_in_editor "# Hello"
            assert_text "Unsaved"
            click_on "Save"
            assert_no_text "Unsaved"
          end
        end

        test "mentor sees scratchpad page" do
          mentor = create :user, handle: "author"
          track = create :track, title: "Elixir"
          exercise = create(:concept_exercise, title: "Strings", track:)
          solution = create(:concept_solution, exercise:)
          discussion = create(:mentor_discussion, solution:, mentor:)
          submission = create(:submission, solution:)
          create(:iteration, solution:, submission:)
          create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

          use_capybara_host do
            sign_in!(mentor)
            visit mentoring_discussion_path(discussion)
            click_on "Scratchpad"

            within("#panel-scratchpad") do
              assert_text "Strings"
              assert_text "Elixir"
              assert_css "img[src='#{track.icon_url}']"
              assert_editor_text "# Some notes"
              assert_no_text "Unsaved"
            end
          end
        end

        test "mentor updates scratchpad page" do
          mentor = create :user, handle: "author"
          exercise = create :concept_exercise
          solution = create(:concept_solution, exercise:)
          discussion = create(:mentor_discussion, solution:, mentor:)
          submission = create(:submission, solution:)
          create(:iteration, solution:, submission:)
          create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

          use_capybara_host do
            sign_in!(mentor)
            visit mentoring_discussion_path(discussion)
            click_on "Scratchpad"
            fill_in_editor "# Hello"
            assert_text "Unsaved"
            click_on "Save"
            assert_no_text "Unsaved"
          end
        end

        test "mentor reverts scratchpad page" do
          mentor = create :user, handle: "author"
          exercise = create :concept_exercise
          solution = create(:concept_solution, exercise:)
          discussion = create(:mentor_discussion, solution:, mentor:)
          submission = create(:submission, solution:)
          create(:iteration, solution:, submission:)
          create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

          use_capybara_host do
            sign_in!(mentor)
            visit mentoring_discussion_path(discussion)
            click_on "Scratchpad"
            fill_in_editor "# Hello"
            click_on "Revert"
            assert_editor_text "# Some notes"
          end
        end
      end
    end
  end
end
