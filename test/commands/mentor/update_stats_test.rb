require "test_helper"

class Mentor::UpdateStatsTest < ActiveSupport::TestCase
  test "update num solutions mentored if requested" do
    mentor = create :user

    Mentor::UpdateNumSolutionsMentored.expects(:call).with(mentor)

    Mentor::UpdateStats.(mentor, update_num_solutions_mentored: true)
  end

  test "does not update num solutions mentored if not request" do
    mentor = create :user

    Mentor::UpdateNumSolutionsMentored.expects(:call).with(mentor).never

    Mentor::UpdateStats.(mentor, update_num_solutions_mentored: false)
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

    Mentor::UpdateStats.(mentor, update_num_solutions_mentored: true, update_satisfaction_rating: true)
  end

  test "updates supermentor role" do
    User::InsidersStatus::Update.stubs(:defer)

    mentor = create :user
    create :user_track_mentorship, user: mentor

    perform_enqueued_jobs do
      99.times do
        create :mentor_discussion, :finished, mentor:, rating: :great
      end

      create :mentor_discussion, :finished, mentor:, rating: :great
    end

    perform_enqueued_jobs do
      Mentor::UpdateStats.(mentor)
    end

    assert mentor.reload.supermentor?
  end
end
