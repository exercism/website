require "test_helper"

class Mentor::StudentRelationship::ToggleBlockedByMentorTest < ActiveSupport::TestCase
  test "creates record and blocks" do
    mentor = create :user
    student = create :user

    Mentor::StudentRelationship::ToggleBlockedByMentor.(mentor, student, true)

    rel = Mentor::StudentRelationship.last
    assert_equal mentor, rel.mentor
    assert_equal student, rel.student
    assert rel.blocked_by_mentor?
  end

  test "creates record without blocked" do
    mentor = create :user
    student = create :user

    Mentor::StudentRelationship::ToggleBlockedByMentor.(mentor, student, false)

    rel = Mentor::StudentRelationship.last
    assert_equal mentor, rel.mentor
    assert_equal student, rel.student
    refute rel.blocked_by_mentor?
  end

  test "changes existing relationship to blocked" do
    rel = create :mentor_student_relationship
    refute rel.blocked_by_mentor?

    Mentor::StudentRelationship::ToggleBlockedByMentor.(rel.mentor, rel.student, true)

    assert rel.reload.blocked_by_mentor?
  end

  test "changes existing relationship to not blocked" do
    rel = create :mentor_student_relationship, blocked_by_mentor: true
    assert rel.blocked_by_mentor?

    Mentor::StudentRelationship::ToggleBlockedByMentor.(rel.mentor, rel.student, false)

    refute rel.reload.blocked_by_mentor?
  end
end
