require 'test_helper'

class Iteration::DiscussionPost::CreateFromMentorTest < ActiveSupport::TestCase
  test "creates discussion post" do
    iteration = create :iteration
    content_markdown = "foobar"
    mentor = create :user
    discussion = create :solution_mentor_discussion, mentor: mentor

    discussion_post = Iteration::DiscussionPost::CreateFromMentor.(
      iteration, 
      discussion,
      content_markdown
    )
    assert discussion_post.persisted?
    assert_equal iteration, discussion_post.iteration
    assert_equal discussion, discussion_post.source
    assert_equal content_markdown, discussion_post.content_markdown
    assert_equal mentor, discussion_post.user
  end
end

