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

  test "scopes and helpers" do
    awaiting_student = create :mentor_discussion, :awaiting_student
    awaiting_mentor = create :mentor_discussion, :awaiting_mentor
    mentor_finished = create :mentor_discussion, :mentor_finished
    finished = create :mentor_discussion, :finished

    # TODO: See where these are used to decide if we need it
    assert_equal [awaiting_student, awaiting_mentor, mentor_finished], Mentor::Discussion.in_progress_for_student
    assert_equal [finished], Mentor::Discussion.finished_for_student
    assert_equal [mentor_finished, finished], Mentor::Discussion.finished_for_mentor

    assert_equal [awaiting_student], Mentor::Discussion.awaiting_student
    assert_equal [awaiting_mentor], Mentor::Discussion.awaiting_mentor
    assert_equal [mentor_finished], Mentor::Discussion.mentor_finished
    assert_equal [finished], Mentor::Discussion.finished

    refute awaiting_student.finished_for_student?
    refute awaiting_mentor.finished_for_student?
    refute mentor_finished.finished_for_student?
    assert finished.finished_for_student?

    refute awaiting_student.finished_for_mentor?
    refute awaiting_mentor.finished_for_mentor?
    assert mentor_finished.finished_for_mentor?
    assert finished.finished_for_mentor?
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
    skip # TODO: Can this be deleted?
    discussion = create :mentor_discussion
    refute discussion.finished?

    discussion.update(finished_at: Time.current)
    assert discussion.finished?
  end

  test "student_finished!" do
    freeze_time do
      discussion = create :mentor_discussion,
        awaiting_mentor_since: Time.current,
        awaiting_student_since: Time.current,
        status: :awaiting_mentor

      discussion.student_finished!

      assert :finished, discussion.status
      assert_nil discussion.awaiting_mentor_since
      assert_nil discussion.awaiting_student_since
      assert_equal Time.current, discussion.finished_at
      assert_equal :student, discussion.finished_by
    end
  end

  test "student_finished! doesn't override mentor finish" do
    freeze_time do
      discussion = create :mentor_discussion,
        awaiting_mentor_since: Time.current,
        awaiting_student_since: Time.current,
        status: :mentor_finished,
        finished_by: :mentor,
        finished_at: 1.week.ago

      discussion.student_finished!

      assert :finished, discussion.status
      assert_nil discussion.awaiting_mentor_since
      assert_nil discussion.awaiting_student_since
      assert_equal 1.week.ago, discussion.finished_at
      assert_equal :mentor, discussion.finished_by
    end
  end

  test "mentor_finished!" do
    freeze_time do
      discussion = create :mentor_discussion,
        awaiting_mentor_since: Time.current,
        awaiting_student_since: nil,
        status: :awaiting_mentor

      discussion.mentor_finished!

      assert :mentor_finished, discussion.status
      assert_nil discussion.awaiting_mentor_since
      assert_equal Time.current, discussion.finished_at
      assert_equal Time.current, discussion.awaiting_student_since
    end
  end

  test "mentor_finished! doesn't modernise existing time" do
    freeze_time do
      original = Time.current - 2.weeks

      discussion = create :mentor_discussion,
        awaiting_mentor_since: Time.current - 1.week,
        awaiting_student_since: original,
        status: :awaiting_mentor

      discussion.mentor_finished!

      assert_nil discussion.awaiting_mentor_since
      assert_equal original, discussion.awaiting_student_since
    end
  end

  test "awaiting_student!" do
    freeze_time do
      discussion = create :mentor_discussion,
        awaiting_mentor_since: Time.current,
        awaiting_student_since: nil,
        status: :awaiting_mentor

      discussion.awaiting_student!

      assert :awaiting_student, discussion.status
      assert_nil discussion.awaiting_mentor_since
      assert_equal Time.current, discussion.awaiting_student_since
    end
  end

  test "awaiting_student! doesn't modernise existing time" do
    freeze_time do
      original = Time.current - 2.weeks

      discussion = create :mentor_discussion,
        awaiting_mentor_since: Time.current - 1.week,
        awaiting_student_since: original,
        status: :awaiting_mentor

      discussion.awaiting_student!

      assert_nil discussion.awaiting_mentor_since
      assert_equal original, discussion.awaiting_student_since
    end
  end

  test "awaiting_mentor!" do
    freeze_time do
      discussion = create :mentor_discussion,
        awaiting_student_since: Time.current,
        awaiting_mentor_since: nil,
        status: :awaiting_student

      discussion.awaiting_mentor!

      assert :awaiting_mentor, discussion.status
      assert_nil discussion.awaiting_student_since
      assert_equal Time.current, discussion.awaiting_mentor_since
    end
  end

  test "awaiting_mentor doesn't modernise existing time" do
    freeze_time do
      original = Time.current - 2.weeks

      discussion = create :mentor_discussion,
        awaiting_student_since: Time.current - 1.week,
        awaiting_mentor_since: original,
        status: :awaiting_student

      discussion.awaiting_mentor!

      assert_nil discussion.awaiting_student_since
      assert_equal original, discussion.awaiting_mentor_since
    end
  end

  test "finished_by symbolizes" do
    assert_nil create(:mentor_discussion, finished_by: nil).finished_by
    assert_equal :mentor, create(:mentor_discussion, finished_by: 'mentor').finished_by
  end
end
