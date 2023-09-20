require 'test_helper'

class MentorActionRequiredTest < ActiveSupport::TestCase
  test 'works as expected' do
    track = create :track
    student = create :user
    mentor = create :user
    create(:user_track, user: student, track:)

    solution = create(:practice_solution, user: student, track:)
    iteration = create(:iteration, solution:)

    request = Mentor::Request::Create.(solution, "Please help")

    discussion = Mentor::Discussion::Create.(mentor, request, iteration.idx, "I'd love to help")
    discussion.reload
    assert_nil discussion.awaiting_mentor_since
    assert discussion.awaiting_student_since

    Mentor::Discussion::ReplyByMentor.(discussion, iteration, "Oh btw...")
    discussion.reload
    assert_nil discussion.awaiting_mentor_since
    assert discussion.awaiting_student_since

    Mentor::Discussion::ReplyByStudent.(discussion, iteration, "Great. That's helpful.")
    discussion.reload
    assert discussion.awaiting_mentor_since
    assert_nil discussion.awaiting_student_since

    Mentor::Discussion::ReplyByMentor.(discussion, iteration, "No probs. How about ...")
    discussion.reload
    assert_nil discussion.awaiting_mentor_since
    assert discussion.awaiting_student_since

    Mentor::Discussion::ReplyByStudent.(discussion, iteration, "Sure, I'll try that now.")
    Mentor::Discussion::AwaitingStudent.(discussion)
    assert_nil discussion.awaiting_mentor_since
    assert discussion.awaiting_student_since
  end
end
