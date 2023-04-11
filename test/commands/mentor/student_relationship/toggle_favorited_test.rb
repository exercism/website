require "test_helper"

class Mentor::StudentRelationship::ToggleFavoritedTest < ActiveSupport::TestCase
  test "fails if they've not had a discussion" do
    Mentor::StudentRelationship::ToggleFavorited.(create(:user), create(:user), false)

    refute Mentor::StudentRelationship.any?
  end

  test "creates record and favorites" do
    mentor = create :user
    student = create :user
    solution = create :concept_solution, user: student
    create(:mentor_discussion, mentor:, solution:)

    Mentor::StudentRelationship::ToggleFavorited.(mentor, student, true)

    rel = Mentor::StudentRelationship.last
    assert_equal mentor, rel.mentor
    assert_equal student, rel.student
    assert rel.favorited?
  end

  test "creates record without favorite" do
    mentor = create :user
    student = create :user
    solution = create :concept_solution, user: student
    create(:mentor_discussion, mentor:, solution:)

    Mentor::StudentRelationship::ToggleFavorited.(mentor, student, false)

    rel = Mentor::StudentRelationship.last
    assert_equal mentor, rel.mentor
    assert_equal student, rel.student
    refute rel.favorited?
  end

  test "changes existing relationship to favorite" do
    mentor = create :user
    student = create :user
    solution = create :concept_solution, user: student
    create(:mentor_discussion, mentor:, solution:)
    rel = create :mentor_student_relationship, mentor:, student:, favorited: false

    refute rel.favorited?

    Mentor::StudentRelationship::ToggleFavorited.(rel.mentor, rel.student, true)

    assert rel.reload.favorited?
  end

  test "changes existing relationship to not favorite" do
    mentor = create :user
    student = create :user
    solution = create :concept_solution, user: student
    create(:mentor_discussion, mentor:, solution:)
    rel = create :mentor_student_relationship, mentor:, student:, favorited: true
    assert rel.favorited?

    Mentor::StudentRelationship::ToggleFavorited.(rel.mentor, rel.student, false)

    refute rel.reload.favorited?
  end
end
