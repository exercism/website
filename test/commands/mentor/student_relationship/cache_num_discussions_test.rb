require "test_helper"

class Mentor::StudentRelationship::CacheNumDiscussionTest < ActiveSupport::TestCase
  test "fails if they've not had a discussion" do
    Mentor::StudentRelationship::CacheNumDiscussions.(create(:user), create(:user))

    refute Mentor::StudentRelationship.any?
  end

  test "creates record with 1" do
    mentor = create :user
    student = create :user
    solution = create :concept_solution, user: student
    create(:mentor_discussion, mentor:, solution:)

    Mentor::StudentRelationship::CacheNumDiscussions.(mentor, student)

    rel = Mentor::StudentRelationship.last
    assert_equal 1, rel.num_discussions
  end

  test "updates existing record" do
    mentor = create :user
    student = create :user
    solution = create :concept_solution, user: student
    create(:mentor_discussion, mentor:, solution:)
    rel = create(:mentor_student_relationship, mentor:, student:)

    Mentor::StudentRelationship::CacheNumDiscussions.(mentor, student)

    assert_equal 1, rel.reload.num_discussions
  end

  test "does not count or touch other records" do
    mentor = create :user
    student = create :user
    solution = create :concept_solution, user: student
    rel_1 = create(:mentor_student_relationship, mentor:, student:)
    create(:mentor_discussion, mentor:, solution:)

    rel_2 = create(:mentor_student_relationship, mentor:)
    create(:mentor_discussion, mentor:)

    rel_3 = create(:mentor_student_relationship, student:)
    create(:mentor_discussion, solution:)

    Mentor::StudentRelationship::CacheNumDiscussions.(mentor, student)

    assert_equal 1, rel_1.reload.num_discussions
    assert_equal 0, rel_2.reload.num_discussions
    assert_equal 0, rel_3.reload.num_discussions
  end
end
