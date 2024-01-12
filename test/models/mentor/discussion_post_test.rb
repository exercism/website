require 'test_helper'

class Iteration::DiscussionPostTest < ActiveSupport::TestCase
  include MarkdownFieldMatchers

  test "generates uuid" do
    post = create :mentor_discussion_post

    assert post.uuid.present?
  end

  test "has markdown fields for feedback" do
    assert_markdown_field(:mentor_discussion_post, :content)
  end

  test "validates content markdown" do
    post = build :mentor_discussion_post
    assert post.valid?

    post.content_markdown = " "
    refute post.valid?
  end

  test "parses markdown correctly" do
    markdown = <<~MD
      # Hello h1
      ## Oooh h2
      ### What now h3
    MD

    html = <<~HTML
      <h3 id="h-hello-h1">Hello h1</h3>
      <h4 id="h-oooh-h2">Oooh h2</h4>
      <h5 id="h-what-now-h3">What now h3</h5>
    HTML

    post = create :mentor_discussion_post, content_markdown: markdown
    assert_equal html, post.content_html
  end

  test "#by_student? returns true if post from student" do
    student = create :user
    solution = create :concept_solution, user: student
    discussion = create(:mentor_discussion, solution:)
    post = create :mentor_discussion_post, discussion:, author: student

    assert post.by_student?
  end

  test "#by_student? returns false if post from mentor" do
    mentor = create :user
    discussion = create(:mentor_discussion, mentor:)
    post = create :mentor_discussion_post, discussion:, author: mentor

    refute post.by_student?
  end

  test "#to_param returns uuid" do
    post = create :mentor_discussion_post

    assert_equal post.uuid, post.to_param
  end
end
