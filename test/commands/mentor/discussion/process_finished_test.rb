require 'test_helper'

class Mentor::Discussion::ProcessFinishedTest < ActiveSupport::TestCase
  [3, 4, 5].each do |rating|
    test "reputation awarded for #{rating}" do
      discussion = create(:mentor_discussion, :student_finished, rating:)

      User::ReputationToken::Create.expects(:defer).with(
        discussion.mentor,
        :mentored,
        discussion:
      )

      Mentor::Discussion::ProcessFinished.(discussion)
    end
  end

  test "reputation not awarded for 1" do
    discussion = create(:mentor_discussion, rating: 1)
    User::ReputationToken::Create.expects(:defer).never
    Mentor::Discussion::ProcessFinished.(discussion)
  end

  test "awards mentor badge" do
    mentor = create :user
    discussions = Array.new(10).map do
      create :mentor_discussion, :student_finished, mentor:, rating: 4
    end

    refute mentor.badges.present?

    perform_enqueued_jobs do
      Mentor::Discussion::ProcessFinished.(discussions.last)
    end

    assert_includes mentor.reload.badges.map(&:class), Badges::MentorBadge
  end

  test "awards mentored trophy" do
    mentor = create :user
    student = create :user

    request = create(:mentor_request, student:)
    discussion = create(:mentor_discussion, :student_finished, rating: 4, mentor:, student:, request:)
    refute student.trophies.present?

    perform_enqueued_jobs do
      Mentor::Discussion::ProcessFinished.(discussion)
    end

    assert_includes student.reload.trophies.map(&:class), Track::Trophies::MentoredTrophy
  end

  test "adds metric" do
    discussion = create :mentor_discussion, :student_finished, rating: 4

    Mentor::Discussion::ProcessFinished.(discussion)
    perform_enqueued_jobs

    assert_equal 1, Metric.count
    metric = Metric.last
    assert_instance_of Metrics::FinishMentoringMetric, metric
    assert_equal discussion.finished_at, metric.occurred_at
    assert_equal discussion.track, metric.track
    assert_equal discussion.student, metric.user
  end

  # This is a super slow test, so I've grouped multiple things in here to
  # save on the performance pain!
  test "updates supermentor and automator role" do
    ruby = create :track, slug: :ruby
    js = create :track, slug: :js
    mentor = create :user
    create :user_track_mentorship, track: ruby, user: mentor
    create :user_track_mentorship, track: js, user: mentor

    98.times do
      create(:mentor_discussion, :student_finished, rating: :great, mentor:)
    end

    # Shouldn't be either at only 99 discussions
    discussion = create(:mentor_discussion, :student_finished, rating: :great, mentor:)
    perform_enqueued_jobs do
      Mentor::Discussion::ProcessFinished.(discussion)
    end
    refute mentor.reload.supermentor?
    refute mentor.automator?(ruby)
    refute mentor.automator?(js)

    # Should be supermentor but not automator for 100 spread over tracks
    solution = create :practice_solution, track: js
    discussion = create(:mentor_discussion, :student_finished, rating: :great, mentor:, solution:)
    perform_enqueued_jobs do
      Mentor::Discussion::ProcessFinished.(discussion)
    end
    assert mentor.reload.supermentor?
    refute mentor.automator?(ruby)
    refute mentor.automator?(js)

    # And should get automator status once we hit the 100th solution that track
    discussion = create(:mentor_discussion, :student_finished, rating: :great, mentor:)
    perform_enqueued_jobs do
      Mentor::Discussion::ProcessFinished.(discussion)
    end
    assert mentor.reload.supermentor?
    assert mentor.automator?(ruby)
    refute mentor.automator?(js)
  end
end
