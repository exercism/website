require "test_helper"

class Mentor::Request::CancelTest < ActiveSupport::TestCase
  test "cancels request" do
    solution = create :practice_solution
    request = create(:mentor_request, solution:)

    Mentor::Request::Cancel.(request)

    assert request.cancelled?
    assert :none, solution.mentoring_status
  end

  test "broadcasts request" do
    request = create :mentor_request

    MentorRequestChannel.expects(:broadcast!).with(request)
    Mentor::Request::Cancel.(request)
  end
end
