require "test_helper"

class AssembleMentorRequestsTest < ActiveSupport::TestCase
  test "proxies correctly" do
    user = create :user
    page = 15
    track_slug = "ruby"
    exercise_slug = "bob"

    ::Mentor::Request::Retrieve.expects(:call).with(
      mentor: user,
      page:,
      track_slug:,
      exercise_slug:,
      sorted: false,
      paginated: false
    ).returns(mock(count: 200))

    Mentor::Request::Retrieve.expects(:call).with(
      mentor: user,
      page:,
      criteria: "Ruby",
      order: "recent",
      track_slug:,
      exercise_slug:
    ).returns(Mentor::Request.page(1).per(1))

    params = {
      page:,
      criteria: "Ruby",
      order: "recent",
      track_slug:,
      exercise_slug:
    }

    AssembleMentorRequests.(user, params)
  end

  test "retrieves requests" do
    user = create :user

    mentored_track = create :track
    create :user_track_mentorship, user:, track: mentored_track
    solution = create :concept_solution, track: mentored_track
    15.times { create :mentor_request, solution: }

    assert_equal SerializePaginatedCollection.(
      Mentor::Request.page(1).per(25),
      serializer: SerializeMentorRequests,
      serializer_args: user,
      meta: {
        unscoped_total: 15
      }
    ), AssembleMentorRequests.(user, {})
  end
end
