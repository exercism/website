require "test_helper"

class Mentor::StudentRelationship::ToggleFavoriteTest < ActiveSupport::TestCase
  test "creates record and favorites" do
    mentor = create :user
    student = create :user

    Mentor::StudentRelationship::ToggleFavorite.(mentor, student, true)

    rel = Mentor::StudentRelationship.last
    assert_equal mentor, rel.mentor
    assert_equal student, rel.student
    assert rel.favorite?
  end

  test "creates record without favorite" do
    mentor = create :user
    student = create :user

    Mentor::StudentRelationship::ToggleFavorite.(mentor, student, false)

    rel = Mentor::StudentRelationship.last
    assert_equal mentor, rel.mentor
    assert_equal student, rel.student
    refute rel.favorite?
  end

  test "changes existing relationship to favorite" do
    rel = create :mentor_student_relationship
    refute rel.favorite?

    Mentor::StudentRelationship::ToggleFavorite.(rel.mentor, rel.student, true)

    assert rel.reload.favorite?
  end

  test "changes existing relationship to not favorite" do
    rel = create :mentor_student_relationship, favorite: true
    assert rel.favorite?

    Mentor::StudentRelationship::ToggleFavorite.(rel.mentor, rel.student, false)

    refute rel.reload.favorite?
  end
end
