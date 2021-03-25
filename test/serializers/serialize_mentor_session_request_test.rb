require 'test_helper'

class SerializeMentorSessionRequestTest < ActiveSupport::TestCase
  test "serializes" do
    request = create :solution_mentor_request

    expected = {
      id: request.uuid,
      comment: request.comment_html,
      updated_at: request.updated_at.iso8601,
      is_locked: request.locked?,
      user: {
        handle: request.user.handle,
        avatar_url: request.user.avatar_url
      },
      links: {
        lock: Exercism::Routes.lock_api_mentoring_request_path(request),
        discussion: Exercism::Routes.api_mentoring_discussions_path
      }
    }

    assert_equal expected, SerializeMentorSessionRequest.(request)
  end
end
