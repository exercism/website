require "test_helper"

class UpdateMentorStatsJobTest < ActiveJob::TestCase
  test "updates num solutions if update_num_solutions set to true" do
    mentor = create :user

    Mentor::UpdateNumSolutionsMentored.expects(:call).with(mentor)

    UpdateMentorStatsJob.perform_now(mentor, update_num_solutions: true)
  end

  test "does not update num solutions if update_num_solutions set to false" do
    mentor = create :user

    Mentor::UpdateNumSolutionsMentored.expects(:call).with(mentor).never

    UpdateMentorStatsJob.perform_now(mentor, update_num_solutions: false)
  end

  test "updates satisfaction rating if update_satisfaction_rating set to true" do
    mentor = create :user

    Mentor::UpdateSatisfactionRating.expects(:call).with(mentor)

    UpdateMentorStatsJob.perform_now(mentor, update_satisfaction_rating: true)
  end

  test "does not update satisfaction rating if update_satisfaction_rating set to false" do
    mentor = create :user

    Mentor::UpdateSatisfactionRating.expects(:call).with(mentor).never

    UpdateMentorStatsJob.perform_now(mentor, update_satisfaction_rating: false)
  end

  test "updates num solutions mentor and satisfaction rating if update_num_solutions and update_satisfaction_rating set to true" do
    mentor = create :user

    Mentor::UpdateSatisfactionRating.expects(:call).with(mentor)

    UpdateMentorStatsJob.perform_now(mentor, update_num_solutions: true, update_satisfaction_rating: true)
  end
end
