require "test_helper"

class Mentor::StudentRelationship::ToggleBlockedByMentorTest < ActiveSupport::TestCase
  test "fails if they've not had a discussion" do
    Mentor::StudentRelationship::ToggleBlockedByMentor.(create(:user), create(:user), false)

    refute Mentor::StudentRelationship.any?
  end

  test "creates record and blocks" do
    mentor = create :user
    student = create :user
    solution = create :concept_solution, user: student
    create(:mentor_discussion, mentor:, solution:)

    Mentor::StudentRelationship::ToggleBlockedByMentor.(mentor, student, true)

    rel = Mentor::StudentRelationship.last
    assert_equal mentor, rel.mentor
    assert_equal student, rel.student
    assert rel.blocked_by_mentor?
  end

  test "creates record without blocked" do
    mentor = create :user
    student = create :user
    solution = create :concept_solution, user: student
    create(:mentor_discussion, mentor:, solution:)

    Mentor::StudentRelationship::ToggleBlockedByMentor.(mentor, student, false)

    rel = Mentor::StudentRelationship.last
    assert_equal mentor, rel.mentor
    assert_equal student, rel.student
    refute rel.blocked_by_mentor?
  end

  test "changes existing relationship to blocked" do
    mentor = create :user
    student = create :user
    solution = create :concept_solution, user: student
    create(:mentor_discussion, mentor:, solution:)
    rel = create :mentor_student_relationship, mentor:, student:, blocked_by_mentor: false
    refute rel.blocked_by_mentor?

    Mentor::StudentRelationship::ToggleBlockedByMentor.(rel.mentor, rel.student, true)

    assert rel.reload.blocked_by_mentor?
  end

  test "changes existing relationship to not blocked" do
    mentor = create :user
    student = create :user
    solution = create :concept_solution, user: student
    create(:mentor_discussion, mentor:, solution:)
    rel = create :mentor_student_relationship, mentor:, student:, blocked_by_mentor: true
    assert rel.blocked_by_mentor?

    Mentor::StudentRelationship::ToggleBlockedByMentor.(rel.mentor, rel.student, false)

    refute rel.reload.blocked_by_mentor?
  end
end
