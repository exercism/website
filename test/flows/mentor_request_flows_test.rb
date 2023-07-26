require "test_helper"

class MentorRequestFlowsTest < ActiveSupport::TestCase
  test "request and get a mentor" do
    track = create :track
    user = create :user
    create(:user_track, user:, track:)

    solution = create(:practice_solution, user:, track:)
    submission = create(:submission, solution:)
    iteration = create(:iteration, submission:)

    mentor = create :user

    assert :none, solution.mentoring_status
    request = Mentor::Request::Create.(solution, "Some text")

    Mentor::Request::Lock.(request, mentor)
    assert request.reload.locked?
    assert :requested, solution.reload.mentoring_status

    discussion = Mentor::Discussion::Create.(
      mentor,
      request,
      iteration.idx,
      "This is great!! Why do you even need a mentor?"
    )
    assert_equal 1, solution.mentor_discussions.size
    assert_equal 1, discussion.posts.size
    assert :in_progress, solution.mentoring_status

    Mentor::Discussion::ReplyByStudent.(discussion, iteration, "Well, because I don't know ALL the answers.")
    assert_equal 2, discussion.posts.size

    Mentor::Discussion::ReplyByMentor.(discussion, iteration, "You know enough. Believe in yourself.")
    assert_equal 3, discussion.posts.size
  end
end
