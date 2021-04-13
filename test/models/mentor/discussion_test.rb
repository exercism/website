require 'test_helper'

class Mentor::DiscussionTest < ActiveSupport::TestCase
  test "solution set to request solution" do
    request = create :mentor_request
    discussion = Mentor::Discussion.create!(
      mentor: create(:user),
      request: request
    )
    assert_equal request.solution, discussion.solution
  end

  test "finished and in_progress scopes" do
    in_progress = create :mentor_discussion, finished_at: nil
    finished = create :mentor_discussion, finished_at: Time.current

    assert_equal [in_progress], Mentor::Discussion.in_progress
    assert_equal [finished], Mentor::Discussion.finished
  end

  test "requires_mentor_action scopes" do
    requires_action = create :mentor_discussion, requires_mentor_action_since: Time.current
    create :mentor_discussion, requires_mentor_action_since: nil

    assert_equal [requires_action], Mentor::Discussion.requires_mentor_action
  end

  test "requires_student_action scopes" do
    requires_action = create :mentor_discussion, requires_student_action_since: Time.current
    create :mentor_discussion, requires_student_action_since: nil

    assert_equal [requires_action], Mentor::Discussion.requires_student_action
  end

  test "#viewable_by? returns true if user is student" do
    student = create :user
    solution = create :concept_solution, user: student
    discussion = create :mentor_discussion, solution: solution

    assert discussion.viewable_by?(student)
  end

  test "#viewable_by? returns true if user is mentor" do
    mentor = create :user
    discussion = create :mentor_discussion, mentor: mentor

    assert discussion.viewable_by?(mentor)
  end

  test "#viewable_by? returns false if user is neither a mentor nor a user" do
    user = create :user
    discussion = create :mentor_discussion

    refute discussion.viewable_by?(user)
  end

  test "finished?" do
    discussion = create :mentor_discussion
    refute discussion.finished?

    discussion.update(finished_at: Time.current)
    assert discussion.finished?
  end

  test "student_action_required!" do
    freeze_time do
      discussion = create :mentor_discussion,
        requires_mentor_action_since: Time.current,
        requires_student_action_since: nil

      discussion.student_action_required!

      assert_nil discussion.requires_mentor_action_since
      assert_equal Time.current, discussion.requires_student_action_since
    end
  end

  test "student_action_required doesn't modernise existing time" do
    freeze_time do
      original = Time.current - 2.weeks

      discussion = create :mentor_discussion,
        requires_mentor_action_since: Time.current - 1.week,
        requires_student_action_since: original

      discussion.student_action_required!

      assert_nil discussion.requires_mentor_action_since
      assert_equal original, discussion.requires_student_action_since
    end
  end

  test "mentor_action_required!" do
    freeze_time do
      discussion = create :mentor_discussion,
        requires_student_action_since: Time.current,
        requires_mentor_action_since: nil

      discussion.mentor_action_required!

      assert_nil discussion.requires_student_action_since
      assert_equal Time.current, discussion.requires_mentor_action_since
    end
  end

  test "mentor_action_required doesn't modernise existing time" do
    freeze_time do
      original = Time.current - 2.weeks

      discussion = create :mentor_discussion,
        requires_student_action_since: Time.current - 1.week,
        requires_mentor_action_since: original

      discussion.mentor_action_required!

      assert_nil discussion.requires_student_action_since
      assert_equal original, discussion.requires_mentor_action_since
    end
  end
end
