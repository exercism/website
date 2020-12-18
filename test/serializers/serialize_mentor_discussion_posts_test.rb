require 'test_helper'

class SerializeMentorDiscussionPostsTest < ActiveSupport::TestCase
  test "serializes post" do
    mentor = create :user, handle: "author"
    discussion = create :solution_mentor_discussion, mentor: mentor
    discussion_post = create(:solution_mentor_discussion_post,
      discussion: discussion,
      author: mentor,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    expected = [
      {
        id: discussion_post.id,
        author_handle: "author",
        author_avatar_url: mentor.avatar_url,
        from_student: false,
        content_html: "<p>Hello</p>\n",
        updated_at: Time.utc(2016, 12, 25).iso8601
      }
    ]
    assert_equal expected, SerializeMentorDiscussionPosts.([discussion_post])
  end
end
