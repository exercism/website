require 'test_helper'

class Mentor::Discussion::HandleStudentAbandonedTest < ActiveSupport::TestCase
  %i[mentor_finished student_timed_out].each do |status|
    test "mark discussion as finished when status is #{status} and finished at least a week ago" do
      freeze_time do
        mentor = create :user
        student = create :user
        discussion = create(:mentor_discussion, status:, mentor:, student:, finished_at: Time.current.utc)

        discussion.update(finished_at: Time.current.utc - 1.day)
        Mentor::Discussion::HandleAbandonedByStudent.()
        refute discussion.finished?

        discussion.update(finished_at: Time.current.utc - 1.week)
        Mentor::Discussion::HandleAbandonedByStudent.()
        assert discussion.reload.finished?
      end
    end
  end

  %i[awaiting_student awaiting_mentor].each do |status|
    test "don't mark discussion as finished when status is #{status} and finished at least a week ago" do
      freeze_time do
        mentor = create :user
        student = create :user
        discussion = create(:mentor_discussion, status:, mentor:, student:, finished_at: Time.current.utc - 1.week)

        refute discussion.finished?

        Mentor::Discussion::HandleAbandonedByStudent.()

        refute discussion.reload.finished?
      end
    end
  end

  test "don't mark discussion as finished when status is mentor_timed_out and finished at least a week ago" do
    freeze_time do
      mentor = create :user
      student = create :user
      discussion = create(:mentor_discussion, status: :mentor_timed_out, mentor:, student:, finished_at: Time.current.utc - 1.week)

      refute discussion.finished?

      Mentor::Discussion::HandleAbandonedByStudent.()

      refute discussion.reload.finished?
    end
  end

  test "don't mark discussion as finished when status is already finished" do
    mentor = create :user
    student = create :user
    finished_at = Time.current.utc - 1.week
    discussion = create(:mentor_discussion, status: :finished, mentor:, student:, finished_at:, updated_at: finished_at)

    Mentor::Discussion::HandleAbandonedByStudent.()

    assert finished_at, discussion.reload.updated_at
  end
end
