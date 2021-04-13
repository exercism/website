require 'test_helper'

class MentorActionRequiredTest < ActiveSupport::TestCase
  test 'works as expected' do
    student = create :user
    mentor = create :user

    solution = create :practice_solution, user: student
    iteration = create :iteration, solution: solution

    request = Mentor::Request::Create.(solution, "Please help")

    discussion = Mentor::Discussion::Create.(mentor, request, iteration.idx, "I'd love to help")
    discussion.reload
    assert_nil discussion.requires_mentor_action_since
    assert discussion.requires_student_action_since

    Mentor::Discussion::ReplyByMentor.(discussion, iteration, "Oh btw...")
    discussion.reload
    assert_nil discussion.requires_mentor_action_since
    assert discussion.requires_student_action_since

    Mentor::Discussion::ReplyByStudent.(discussion, iteration, "Great. That's helpful.")
    discussion.reload
    assert discussion.requires_mentor_action_since
    assert_nil discussion.requires_student_action_since

    Mentor::Discussion::ReplyByMentor.(discussion, iteration, "No probs. How about ...")
    discussion.reload
    assert_nil discussion.requires_mentor_action_since
    assert discussion.requires_student_action_since

    Mentor::Discussion::ReplyByStudent.(discussion, iteration, "Sure, I'll try that now.")
    discussion.student_action_required!
    assert_nil discussion.requires_mentor_action_since
    assert discussion.requires_student_action_since
  end
end
