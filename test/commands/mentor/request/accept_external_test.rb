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
  end

  test "creates and returns discussion" do
    mentor = create :user
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track

    discussion = Mentor::Request::AcceptExternal.(mentor, solution)

    assert Mentor::Request.last, discussion.request
    assert discussion.request.external
    assert discussion.request.fulfilled?
    assert mentor, discussion.mentor
  end

  test "can be accepted fail if no slots are avalable" do
    mentor = create :user, reputation: 0
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track

    # Fill up the queue
    create :mentor_discussion, mentor: mentor, solution: solution
    create :mentor_discussion, mentor: mentor, solution: solution

    Mentor::Request::AcceptExternal.(mentor, solution)

    assert_equal 3, Mentor::Request.count
  end
end
