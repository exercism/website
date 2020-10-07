require 'test_helper'

class Submission::DiscussionPostTest < ActiveSupport::TestCase
  include MarkdownFieldMatchers

  test "has markdown fields for feedback" do
    assert_markdown_field(:submission_discussion_post, :content)
  end

  test "validates content markdown" do
    post = build :submission_discussion_post
    assert post.valid?

    post.content_markdown = " "
    refute post.valid?
  end
end
