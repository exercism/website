require 'test_helper'

class SerializeMentorSessionRequestTest < ActiveSupport::TestCase
  test "serializes" do
    user = create :user
    solution = create :concept_solution
    request = create(:mentor_request, solution:)
    create(:iteration, solution:)

    expected = {
      uuid: request.uuid,
      comment: SerializeMentorDiscussionPost.(Mentor::RequestComment.from(request), user),
      is_locked: request.locked?,
      locked_until: nil,
      student: {
        handle: request.student.handle,
        avatar_url: request.student.avatar_url
      },
      track: {
        title: request.track.title
      },
      links: {
        lock: Exercism::Routes.lock_api_mentoring_request_path(request),
        extend_lock: Exercism::Routes.extend_lock_api_mentoring_request_path(request.uuid),
        cancel: Exercism::Routes.cancel_api_mentoring_request_path(request),
        discussion: Exercism::Routes.api_mentoring_discussions_path
      }
    }

    assert_equal expected, SerializeMentorSessionRequest.(request, user)
  end
end
