require "test_helper"

class Mentor::StudentRelationship::ToggleBlockedTest < ActiveSupport::TestCase
  test "creates record and blocks" do
    mentor = create :user
    student = create :user

    Mentor::StudentRelationship::ToggleBlocked.(mentor, student, true)

    rel = Mentor::StudentRelationship.last
    assert_equal mentor, rel.mentor
    assert_equal student, rel.student
    assert rel.blocked?
  end

  test "creates record without blocked" do
    mentor = create :user
    student = create :user

    Mentor::StudentRelationship::ToggleBlocked.(mentor, student, false)

    rel = Mentor::StudentRelationship.last
    assert_equal mentor, rel.mentor
    assert_equal student, rel.student
    refute rel.blocked?
  end

  test "changes existing relationship to blocked" do
    rel = create :mentor_student_relationship
    refute rel.blocked?

    Mentor::StudentRelationship::ToggleBlocked.(rel.mentor, rel.student, true)

    assert rel.reload.blocked?
  end

  test "changes existing relationship to not blocked" do
    rel = create :mentor_student_relationship, blocked: true
    assert rel.blocked?

    Mentor::StudentRelationship::ToggleBlocked.(rel.mentor, rel.student, false)

    refute rel.reload.blocked?
  end
end
