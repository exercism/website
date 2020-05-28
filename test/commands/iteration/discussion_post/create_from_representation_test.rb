require 'test_helper'

class Iteration::DiscussionPost::CreateFromRepresentationTest < ActiveSupport::TestCase
  test "creates discussion post" do
    iteration = create :iteration
    iteration_representation = create :iteration_representation

    feedback_markdown = "foobar"
    feedback_author = create :user
    exercise_representation = create :exercise_representation, feedback_markdown: feedback_markdown, feedback_author: feedback_author

    discussion_post = Iteration::DiscussionPost::CreateFromRepresentation.(
      iteration, 
      iteration_representation,
      exercise_representation
    )
    assert discussion_post.persisted?
    assert_equal iteration, discussion_post.iteration
    assert_equal iteration_representation, discussion_post.source
    assert_equal feedback_markdown, discussion_post.content_markdown
    assert_equal feedback_author, discussion_post.user
  end
end
