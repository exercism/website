require 'test_helper'

class SerializeSolutionCommentTest < ActiveSupport::TestCase
  test "for same user" do
    comment = create(:solution_comment)
    solution = comment.solution
    expected = {
      uuid: comment.uuid,
      author: {
        handle: comment.author.handle,
        flair: comment.author.flair,
        avatar_url: comment.author.avatar_url,
        reputation: comment.author.formatted_reputation
      },
      content_markdown: comment.content_markdown,
      content_html: comment.content_html,
      updated_at: comment.updated_at.iso8601,
      links: {
        edit: Exercism::Routes.api_track_exercise_community_solution_comment_url(solution.track, solution.exercise, solution.user,
          comment),
        delete: Exercism::Routes.api_track_exercise_community_solution_comment_url(solution.track, solution.exercise, solution.user,
          comment)
      }
    }

    assert_equal expected, SerializeSolutionComment.(comment, comment.author)
  end

  test "no links for different user" do
    actual = SerializeSolutionComment.(create(:solution_comment), create(:user))
    assert_empty actual[:links]
  end
end
