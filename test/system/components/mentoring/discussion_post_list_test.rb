require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Mentoring
    class DiscussionTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows correct information" do
        mentor = create :user, handle: "author"
        discussion = create :solution_mentor_discussion, mentor: mentor
        iteration = create :iteration
        create(:solution_mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: mentor,
          content_markdown: "Hello",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!
          visit test_components_mentoring_discussion_post_list_path(
            discussion_id: discussion.id,
            iteration_id: iteration.id
          )
        end

        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        refute_text "Student"
        assert_text "Hello"
      end
    end
  end
end
