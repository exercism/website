require 'test_helper'

class Iteration::DiscussionPostTest < ActiveSupport::TestCase
  include MarkdownFieldMatchers

  test "has markdown fields for feedback" do
    assert_markdown_field(:solution_mentor_discussion_post, :content)
  end

  test "validates content markdown" do
    post = build :solution_mentor_discussion_post
    assert post.valid?

    post.content_markdown = " "
    refute post.valid?
  end
end
