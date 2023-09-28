require "test_helper"

class Mentor::UpdateStatsTest < ActiveSupport::TestCase
  test "updates things correctly" do
    mentor = create :user
    track = create :track

    User::ResetCache.expects(:call).with(mentor, :num_students_mentored)
    User::ResetCache.expects(:call).with(mentor, :num_solutions_mentored)
    Mentor::UpdateSatisfactionPercentage.expects(:call).with(mentor)

    Mentor::UpdateStats.(mentor, track)
  end

  test "updates supermentor role" do
    User::InsidersStatus::Update.stubs(:defer)

    mentor = create :user
    track = create :track
    create(:user_track_mentorship, user: mentor, track:)

    99.times do
      create :mentor_discussion, :finished, mentor:, rating: :great
    end

    perform_enqueued_jobs { Mentor::UpdateStats.(mentor, track) }
    refute mentor.reload.supermentor?

    create :mentor_discussion, :finished, mentor:, rating: :great
    perform_enqueued_jobs { Mentor::UpdateStats.(mentor, track) }
    assert mentor.reload.supermentor?
  end

  test "recalculates num_solutions_mentored" do
    mentor = create :user
    student = create :user
    other_student = create :user
    track = create :track
    mentor.num_solutions_mentored # Cache it

    # Sanity check
    assert_equal 0, mentor.num_students_mentored
    assert_equal 0, mentor.num_solutions_mentored

    create(:mentor_discussion, mentor:, request: create(:mentor_request, student:))
    Mentor::UpdateStats.(mentor, track)
    assert_equal 0, mentor.reload.num_students_mentored
    assert_equal 0, mentor.reload.num_solutions_mentored

    create(:mentor_discussion, mentor:, status: :mentor_finished, request: create(:mentor_request, student:))
    Mentor::UpdateStats.(mentor, track)
    assert_equal 0, mentor.reload.num_students_mentored
    assert_equal 0, mentor.reload.num_solutions_mentored

    create(:mentor_discussion, mentor:, status: :finished, request: create(:mentor_request, student:))
    create(:mentor_discussion, mentor:, status: :finished, request: create(:mentor_request, student:))
    create(:mentor_discussion, mentor:, status: :finished, request: create(:mentor_request, student: other_student))
    Mentor::UpdateStats.(mentor, track)
    assert_equal 2, mentor.reload.num_students_mentored
    assert_equal 3, mentor.reload.num_solutions_mentored
  end
end
