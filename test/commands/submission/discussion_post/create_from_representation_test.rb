require 'test_helper'

class Submission::DiscussionPost::CreateFromRepresentationTest < ActiveSupport::TestCase
  test "creates discussion post" do
    submission = create :submission
    submission_representation = create :submission_representation

    feedback_markdown = "foobar"
    feedback_author = create :user
    exercise_representation = create :exercise_representation,
      feedback_markdown: feedback_markdown,
      feedback_author: feedback_author

    discussion_post = Submission::DiscussionPost::CreateFromRepresentation.(
      submission,
      submission_representation,
      exercise_representation
    )
    assert discussion_post.persisted?
    assert_equal submission, discussion_post.submission
    assert_equal submission_representation, discussion_post.source
    assert_equal feedback_markdown, discussion_post.content_markdown
    assert_equal feedback_author, discussion_post.user
  end
end
