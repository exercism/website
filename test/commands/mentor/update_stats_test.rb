require "test_helper"

class Mentor::UpdateStatsTest < ActiveSupport::TestCase
  test "update num solutions mentored if requested" do
    mentor = create :user

    User::ResetCache.expects(:call).with(mentor, :num_students_mentored)
    User::ResetCache.expects(:call).with(mentor, :num_solutions_mentored)

    Mentor::UpdateStats.(mentor, update_counts: true)
  end

  test "does not update num solutions mentored if not request" do
    mentor = create :user

    User::ResetCache.expects(:call).with(mentor, :num_students_mentored).never
    User::ResetCache.expects(:call).with(mentor, :num_solutions_mentored).never

    Mentor::UpdateStats.(mentor, update_counts: false)
  end

  test "update satisfaction rating if requested" do
    mentor = create :user

    Mentor::UpdateSatisfactionPercentage.expects(:call).with(mentor)

    Mentor::UpdateStats.(mentor, update_satisfaction_rating: true)
  end

  test "does not update satisfaction rating if not requested" do
    mentor = create :user

    Mentor::UpdateSatisfactionPercentage.expects(:call).with(mentor).never

    Mentor::UpdateStats.(mentor, update_satisfaction_rating: false)
  end

  test "updates num solutions mentored and satisfaction rating if requested" do
    mentor = create :user

    Mentor::UpdateSatisfactionPercentage.expects(:call).with(mentor)

    Mentor::UpdateStats.(mentor, update_counts: true, update_satisfaction_rating: true)
  end

  test "updates supermentor role" do
    User::InsidersStatus::Update.stubs(:defer)

    mentor = create :user
    create :user_track_mentorship, user: mentor

    99.times do
      create :mentor_discussion, :finished, mentor:, rating: :great
    end

    perform_enqueued_jobs { Mentor::UpdateStats.(mentor, update_counts: true) }
    refute mentor.reload.supermentor?

    create :mentor_discussion, :finished, mentor:, rating: :great
    perform_enqueued_jobs { Mentor::UpdateStats.(mentor, update_counts: true) }
    assert mentor.reload.supermentor?
  end

  test "recalculates num_solutions_mentored" do
    mentor = create :user
    student = create :user
    mentor.num_solutions_mentored # Cache it

    # Sanity check
    assert_equal 0, mentor.num_students_mentored
    assert_equal 0, mentor.num_solutions_mentored

    create(:mentor_discussion, mentor:, request: create(:mentor_request, student:))
    Mentor::UpdateStats.(mentor, update_counts: true)
    assert_equal 0, mentor.reload.num_students_mentored
    assert_equal 0, mentor.reload.num_solutions_mentored

    create(:mentor_discussion, mentor:, status: :mentor_finished, request: create(:mentor_request, student:))
    Mentor::UpdateStats.(mentor, update_counts: true)
    assert_equal 0, mentor.reload.num_students_mentored
    assert_equal 0, mentor.reload.num_solutions_mentored

    create(:mentor_discussion, mentor:, status: :finished, request: create(:mentor_request, student:))
    create(:mentor_discussion, mentor:, status: :finished, request: create(:mentor_request, student:))
    Mentor::UpdateStats.(mentor, update_counts: true)
    assert_equal 2, mentor.reload.num_students_mentored
    assert_equal 2, mentor.reload.num_solutions_mentored
  end
end
