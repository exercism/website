require "test_helper"

class Mentor::StudentRelationship::ToggleFavoritedTest < ActiveSupport::TestCase
  test "creates record and favorites" do
    mentor = create :user
    student = create :user

    Mentor::StudentRelationship::ToggleFavorited.(mentor, student, true)

    rel = Mentor::StudentRelationship.last
    assert_equal mentor, rel.mentor
    assert_equal student, rel.student
    assert rel.favorited?
  end

  test "creates record without favorite" do
    mentor = create :user
    student = create :user

    Mentor::StudentRelationship::ToggleFavorited.(mentor, student, false)

    rel = Mentor::StudentRelationship.last
    assert_equal mentor, rel.mentor
    assert_equal student, rel.student
    refute rel.favorited?
  end

  test "changes existing relationship to favorite" do
    rel = create :mentor_student_relationship
    refute rel.favorited?

    Mentor::StudentRelationship::ToggleFavorited.(rel.mentor, rel.student, true)

    assert rel.reload.favorited?
  end

  test "changes existing relationship to not favorite" do
    rel = create :mentor_student_relationship, favorited: true
    assert rel.favorited?

    Mentor::StudentRelationship::ToggleFavorited.(rel.mentor, rel.student, false)

    refute rel.reload.favorited?
  end
end
