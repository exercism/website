require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/websockets_helpers"

module Components
  module Mentoring
    class DiscussionPanelListTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include WebsocketsHelpers

      test "shows correct information" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution
        create(:solution_mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: mentor,
          content_markdown: "Hello",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_post_panel_path(
            discussion_id: discussion.id,
            iteration_id: iteration.id
          )
        end

        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        refute_text "Student"
        assert_text "Hello"
      end

      test "refetches when new post comes in" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_post_panel_path(
            discussion_id: discussion.id,
            iteration_id: iteration.id
          )
          create(:solution_mentor_discussion_post,
            discussion: discussion,
            iteration: iteration,
            author: mentor,
            content_markdown: "Hello",
            updated_at: Time.current)
          wait_for_websockets
          DiscussionPostListChannel.notify!(discussion, iteration)
        end

        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        refute_text "Student"
        assert_text "Hello"
      end
    end
  end
end
