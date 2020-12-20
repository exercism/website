require 'test_helper'

class SerializeMentorDiscussionPostTest < ActiveSupport::TestCase
  test "serializes posts for author" do
    author = create :user, handle: "author"
    discussion_post = create(:solution_mentor_discussion_post,
      author: author,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    expected = {
      id: discussion_post.uuid,
      author_handle: "author",
      author_avatar_url: author.avatar_url,
      by_student: false,
      content_markdown: "Hello",
      content_html: "<p>Hello</p>\n",
      updated_at: Time.utc(2016, 12, 25).iso8601,
      links: {
        update: Exercism::Routes.api_mentor_discussion_post_url(discussion_post)
      }
    }
    assert_equal expected, SerializeMentorDiscussionPost.(discussion_post, author)
  end

  test "serializes posts for non-author" do
    user = create :user
    author = create :user, handle: "author"
    discussion = create :solution_mentor_discussion, mentor: author
    discussion_post = create(:solution_mentor_discussion_post,
      discussion: discussion,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    expected = {
      id: discussion_post.uuid,
      author_handle: "author",
      author_avatar_url: author.avatar_url,
      by_student: false,
      content_markdown: "Hello",
      content_html: "<p>Hello</p>\n",
      updated_at: Time.utc(2016, 12, 25).iso8601,
      links: {}
    }
    assert_equal expected, SerializeMentorDiscussionPost.(discussion_post, user)
  end
end
