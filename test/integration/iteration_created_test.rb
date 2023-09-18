require 'test_helper'

# I placed this test here because it's between a unit and system test.
# We can't put this in a system test because we can't really test what happens on the browser.
# This process involves actions which are more backend involved.

class IterationCreatedTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "notifies mentors and marks discussions as awaiting student" do
    student = create :user, handle: "student"
    mentor = create :user
    track = create :track, title: "Ruby"
    exercise = create(:concept_exercise, title: "Strings", track:)
    solution = create(:concept_solution, user: student, exercise:)
    discussion = create(:mentor_discussion, solution:, mentor:)
    submission = create(:submission, solution:)

    perform_enqueued_jobs do
      Iteration::Create.(solution, submission)
    end

    assert_equal :awaiting_mentor, discussion.reload.status
    email = ActionMailer::Base.deliveries.first
    assert_equal(
      "[Mentoring] student has submitted a new iteration on the solution you are mentoring for Ruby/Strings",
      email.subject
    )

    ActionMailer::Base.deliveries.clear
  end
end
