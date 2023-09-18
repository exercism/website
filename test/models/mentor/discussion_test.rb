require 'test_helper'

class Mentor::DiscussionTest < ActiveSupport::TestCase
  test "solution set to request solution" do
    request = create :mentor_request
    discussion = Mentor::Discussion.create!(
      mentor: create(:user),
      request:
    )
    assert_equal request.solution, discussion.solution
  end

  test "scopes and helpers" do
    awaiting_student = create :mentor_discussion, :awaiting_student
    awaiting_mentor = create :mentor_discussion, :awaiting_mentor
    mentor_finished = create :mentor_discussion, :mentor_finished, rating: :great
    finished = create :mentor_discussion, :finished, rating: :problematic

    # TODO: See where these are used to decide if we need it
    assert_equal [awaiting_student, awaiting_mentor, mentor_finished], Mentor::Discussion.in_progress_for_student
    assert_equal [finished], Mentor::Discussion.finished_for_student
    assert_equal [mentor_finished, finished], Mentor::Discussion.finished_for_mentor

    assert_equal [awaiting_student], Mentor::Discussion.awaiting_student
    assert_equal [awaiting_mentor], Mentor::Discussion.awaiting_mentor
    assert_equal [mentor_finished], Mentor::Discussion.mentor_finished
    assert_equal [finished], Mentor::Discussion.finished

    assert_equal [awaiting_student, awaiting_mentor, mentor_finished], Mentor::Discussion.not_negatively_rated

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
    discussion = create(:mentor_discussion, solution:)

    assert discussion.viewable_by?(student)
  end

  test "#viewable_by? returns true if user is mentor" do
    mentor = create :user
    discussion = create(:mentor_discussion, mentor:)

    assert discussion.viewable_by?(mentor)
  end

  test "#viewable_by? returns true if user is admin" do
    admin = create :user, roles: [:admin]
    discussion = create :mentor_discussion

    assert discussion.viewable_by?(admin)
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

  test "mentor_finished! doesn't modernize existing time" do
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

  test "awaiting_student! doesn't modernize existing time" do
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

  test "awaiting_student! doesn't override student_finished" do
    discussion = create :mentor_discussion
    discussion.student_finished!
    discussion.awaiting_student!

    assert :finished, discussion.status
    assert_nil discussion.awaiting_mentor_since
    assert_nil discussion.awaiting_student_since
  end

  test "awaiting_student! doesn't override mentor_finished" do
    discussion = create :mentor_discussion
    discussion.mentor_finished!
    discussion.awaiting_student!

    discussion.reload
    assert :finished, discussion.status
    assert_nil discussion.awaiting_mentor_since
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

  test "awaiting_mentor doesn't modernize existing time" do
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

  test "awaiting_mentor! doesn't override student_finished" do
    discussion = create :mentor_discussion
    discussion.student_finished!
    discussion.awaiting_mentor!

    assert :finished, discussion.status
    assert_nil discussion.awaiting_mentor_since
    assert_nil discussion.awaiting_student_since
  end

  test "awaiting_mentor! doesn't override mentor_finished" do
    discussion = create :mentor_discussion
    discussion.mentor_finished!
    discussion.awaiting_mentor!

    assert :finished, discussion.status
    assert_nil discussion.awaiting_mentor_since
  end

  test "finished_by symbolizes" do
    assert_nil create(:mentor_discussion, finished_by: nil).finished_by
    assert_equal :mentor, create(:mentor_discussion, finished_by: 'mentor').finished_by
  end

  test "num_posts is updated" do
    discussion = create :mentor_discussion
    assert_equal 0, discussion.num_posts # Sanity

    create(:mentor_discussion_post, discussion:)
    assert_equal 1, discussion.num_posts # Sanity
  end

  test "student_helpers" do
    discussion = create :mentor_discussion
    assert_equal discussion.student.handle, discussion.student_handle
    assert_equal discussion.student.name, discussion.student_name
    assert_equal discussion.student.avatar_url, discussion.student_avatar_url

    discussion = create :mentor_discussion, anonymous_mode: true
    assert_equal "anonymous", discussion.student_handle
    assert_equal "User in Anonymous mode", discussion.student_name
    assert_nil discussion.student_avatar_url
  end

  test "recalculates num_solutions_mentored" do
    mentor = create :user

    # Sanity check
    assert_equal 0, mentor.num_solutions_mentored

    discussion_1 = create(:mentor_discussion, mentor:)
    discussion_2 = create(:mentor_discussion, mentor:)
    discussion_3 = create(:mentor_discussion, mentor:)
    perform_enqueued_jobs

    perform_enqueued_jobs do
      discussion_1.student_finished!
    end
    mentor.data.reload

    assert_equal 1, mentor.reload.num_solutions_mentored

    perform_enqueued_jobs do
      discussion_2.finished!
    end
    assert_equal 2, mentor.reload.num_solutions_mentored

    perform_enqueued_jobs do
      discussion_3.finished!
    end
    assert_equal 3, mentor.reload.num_solutions_mentored
  end

  test "recalculates mentor_satisfaction_percentage" do
    mentor = create :user

    # Sanity check
    assert_nil mentor.mentor_satisfaction_percentage

    create :mentor_discussion, mentor:, status: :finished, rating: :great
    perform_enqueued_jobs
    reset_user_cache(mentor)
    assert_equal 100, mentor.reload.mentor_satisfaction_percentage

    create :mentor_discussion, mentor:, status: :finished, rating: :problematic
    perform_enqueued_jobs
    reset_user_cache(mentor)
    assert_equal 50, mentor.reload.mentor_satisfaction_percentage

    create :mentor_discussion, mentor:, status: :mentor_finished, rating: :acceptable
    perform_enqueued_jobs
    reset_user_cache(mentor)
    assert_equal 67, mentor.reload.mentor_satisfaction_percentage

    create :mentor_discussion, mentor:, status: :mentor_finished, rating: :good
    perform_enqueued_jobs
    reset_user_cache(mentor)
    assert_equal 75, mentor.reload.mentor_satisfaction_percentage
  end

  test "recalculates num_finished_discussions" do
    mentor = create :user
    mentorship = create :user_track_mentorship, user: mentor

    discussion_1 = create(:mentor_discussion, mentor:)
    discussion_2 = create(:mentor_discussion, mentor:)
    discussion_3 = create(:mentor_discussion, mentor:)

    # Sanity check
    assert_equal 0, mentorship.num_finished_discussions

    perform_enqueued_jobs do
      discussion_1.student_finished!
    end
    assert_equal 1, mentorship.reload.num_finished_discussions

    perform_enqueued_jobs do
      discussion_2.mentor_finished!
    end
    assert_equal 1, mentorship.reload.num_finished_discussions

    perform_enqueued_jobs do
      discussion_3.student_finished!
    end
    assert_equal 2, mentorship.reload.num_finished_discussions
  end

  test "mentor_satisfaction_percentage is rounded up" do
    mentor = create :user

    perform_enqueued_jobs do
      create :mentor_discussion, mentor:, status: :finished, rating: :great
      create :mentor_discussion, mentor:, status: :mentor_finished, rating: :problematic
      create :mentor_discussion, mentor:, status: :finished, rating: :problematic
    end

    reset_user_cache(mentor)

    assert_equal 34, mentor.reload.mentor_satisfaction_percentage
  end

  test "does not update mentor stats if status is unchanged" do
    mentor = create :user
    discussion = create(:mentor_discussion, mentor:)

    perform_enqueued_jobs do
      Mentor::UpdateStats.expects(:call).never

      discussion.update(rating: :great)
    end
  end

  %i[awaiting_student awaiting_mentor mentor_finished].each do |status|
    test "does not update num discussions finished if status is #{status}" do
      mentor = create :user
      # Use status: finished to ensure we always change state
      discussion = create(:mentor_discussion, mentor:, status: :finished)

      perform_enqueued_jobs do
        Mentor::Discussion::UpdateNumFinishedDiscussions.expects(:call).never

        discussion.update(status:)
      end
    end
  end
end
