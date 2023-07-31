require "test_helper"

class Mentor::Request::AcceptExternalTest < ActiveSupport::TestCase
  test "creates request that is immediately fulfilled" do
    mentor = create :user
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track

    Mentor::Request::AcceptExternal.(mentor, solution)

    assert_equal 1, Mentor::Request.count
    request = Mentor::Request.last
    assert_equal solution, request.solution
    assert_equal "This is a private review session", request.comment_markdown
    assert request.fulfilled?
    assert request.external?
  end

  test "creates and returns discussion" do
    mentor = create :user
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track

    discussion = Mentor::Request::AcceptExternal.(mentor, solution)

    assert Mentor::Request.last, discussion.request
    assert mentor, discussion.mentor
    assert discussion.external
  end

  test "can be accepted fail if no slots are avalable" do
    mentor = create :user, reputation: 0
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track

    # Fill up the queue
    create(:mentor_discussion, mentor:, solution:)
    create(:mentor_discussion, mentor:, solution:)

    Mentor::Request::AcceptExternal.(mentor, solution)

    assert_equal 3, Mentor::Request.count
  end

  test "adds metric" do
    mentor = create :user
    student = create :user
    track = create :track
    solution = create :practice_solution, track:, user: student
    create(:user_track, user: student, track:)

    discussion = Mentor::Request::AcceptExternal.(mentor, solution)
    perform_enqueued_jobs

    assert_equal 1, Metric.count
    metric = Metric.last
    assert_instance_of Metrics::RequestPrivateMentoringMetric, metric
    assert_equal discussion.request.created_at, metric.occurred_at
    assert_equal track, metric.track
    assert_equal student, metric.user
    assert_equal 'US', metric.country_code
  end
end
