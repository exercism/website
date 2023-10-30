require "test_helper"

class User::DestroyAccountTest < ActiveSupport::TestCase
  test "resets then destroys" do
    user = create :user

    # Create all the things the person might have
    rel_1 = create :mentor_student_relationship, mentor: user
    rel_2 = create :mentor_student_relationship, student: user
    rel_3 = create :mentor_student_relationship
    subscription = create(:payments_subscription, user:)
    payment_1 = create(:payments_payment, user:, subscription:)
    payment_2 = create(:payments_payment, user:)

    User::ResetAccount.expects(:call).with(user)

    User::DestroyAccount.(user)

    assert_raises ActiveRecord::RecordNotFound, &proc { user.reload }
    assert_raises ActiveRecord::RecordNotFound, &proc { rel_1.reload }
    assert_raises ActiveRecord::RecordNotFound, &proc { rel_2.reload }
    assert_raises ActiveRecord::RecordNotFound, &proc { subscription.reload }
    assert_raises ActiveRecord::RecordNotFound, &proc { payment_1.reload }
    assert_raises ActiveRecord::RecordNotFound, &proc { payment_2.reload }
    assert_nothing_raised { rel_3.reload }
  end

  test "test works without user track" do
    create :user, :ghost

    user = create :user
    solution = create(:practice_solution, user:)
    submission = create(:submission, solution:)
    iteration = create(:iteration, solution:, submission:)
    solution.update!(published_iteration: iteration)

    User::DestroyAccount.(user)
  end

  test "removes their solutions from the index" do
    Solution::PublishIteration.any_instance.stubs(:call)

    create :user, :ghost

    user = create :user
    solution = create(:practice_solution, user:)
    submission = create(:submission, solution:)
    create(:iteration, solution:, submission:)
    ut = create :user_track, track: solution.track

    # Run this to clear out all the jobs above
    perform_enqueued_jobs

    perform_enqueued_jobs do
      Solution::Publish.(solution, ut, 1)
    end
    sleep(1) # It takes a second for cloudsearch to actually update its index
    assert_equal 1, Solution::SearchCommunitySolutions.(solution.exercise).length

    # Don't wrap perform_enqueued_jobs around this, do it afterwards
    # and sleep for 0.1 to ensure that user is actually deleted etc
    # before the enqueueed jobs runs.
    User::DestroyAccount.(user)
    sleep(0.1)

    perform_enqueued_jobs
    assert_empty Solution::SearchCommunitySolutions.(solution.exercise)
  end
end
