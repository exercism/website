require 'test_helper'

class Mentor::Discussion::FinishAbandonedTest < ActiveSupport::TestCase
  %i[mentor_finished student_timed_out].each do |status|
    test "mark discussion as finished when status is #{status} and finished at least a week ago" do
      freeze_time do
        discussion = create(:mentor_discussion, status:, finished_at: Time.current.utc)

        discussion.update(finished_at: Time.current.utc - 1.day)
        Mentor::Discussion::FinishAbandoned.()
        refute discussion.finished?

        discussion.update(finished_at: Time.current.utc - 1.week)
        Mentor::Discussion::FinishAbandoned.()
        assert discussion.reload.finished?
      end
    end

    test "reputation awarded when abandoning from status #{status}" do
      finished_at = Time.current.utc - 1.week
      discussion = create(:mentor_discussion, status:, finished_at:, updated_at: finished_at)

      User::ReputationToken::Create.expects(:defer).with(
        discussion.mentor,
        :mentored,
        discussion:
      )

      Mentor::Discussion::FinishAbandoned.()
    end

    test "awards mentor badge when abandoning from status #{status}" do
      mentor = create :user
      9.times do |_idx|
        create :mentor_discussion, :student_finished, mentor:
      end

      finished_at = Time.current.utc - 1.week
      create(:mentor_discussion, status:, mentor:, finished_at:, updated_at: finished_at)
      refute mentor.badges.present?

      perform_enqueued_jobs do
        Mentor::Discussion::FinishAbandoned.()
      end

      assert_includes mentor.reload.badges.map(&:class), Badges::MentorBadge
    end

    test "awards mentored trophy when abandoning from status #{status}" do
      student = create :user
      finished_at = Time.current.utc - 1.week
      request = create(:mentor_request, student:)
      create(:mentor_discussion, status:, student:, finished_at:, updated_at: finished_at, request:)
      refute student.badges.present?

      perform_enqueued_jobs do
        Mentor::Discussion::FinishAbandoned.()
      end

      assert_includes student.reload.trophies.map(&:class), Track::Trophies::MentoredTrophy
    end

    test "adds metric when abandoning from status #{status}" do
      student = create :user
      finished_at = Time.current.utc - 1.week
      discussion = create(:mentor_discussion, status:, student:, finished_at:, updated_at: finished_at)

      perform_enqueued_jobs do
        Mentor::Discussion::FinishAbandoned.()
      end

      assert_equal 1, Metric.count
      metric = Metric.last
      assert_instance_of Metrics::FinishMentoringMetric, metric
      assert_equal discussion.finished_at, metric.occurred_at
      assert_equal discussion.track, metric.track
      assert_equal discussion.student, metric.user
    end
  end

  %i[awaiting_student awaiting_mentor].each do |status|
    test "don't mark discussion as finished when status is #{status} and finished at least a week ago" do
      freeze_time do
        discussion = create(:mentor_discussion, status:, finished_at: Time.current.utc - 1.week)

        refute discussion.finished?

        Mentor::Discussion::FinishAbandoned.()

        refute discussion.reload.finished?
      end
    end
  end

  test "don't mark discussion as finished when status is mentor_timed_out and finished at least a week ago" do
    freeze_time do
      discussion = create(:mentor_discussion, status: :mentor_timed_out, finished_at: Time.current.utc - 1.week)

      refute discussion.finished?

      Mentor::Discussion::FinishAbandoned.()

      refute discussion.reload.finished?
    end
  end

  test "don't mark discussion as finished when status is already finished" do
    finished_at = Time.current.utc - 1.week
    discussion = create(:mentor_discussion, status: :finished, finished_at:, updated_at: finished_at)

    Mentor::Discussion::FinishAbandoned.()

    assert finished_at, discussion.reload.updated_at
  end
end
