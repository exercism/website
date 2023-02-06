require "test_helper"

class Exercise::Approach::Contributorship::CreateTest < ActiveSupport::TestCase
  test "awards reputation" do
    user = create :user
    approach = create :exercise_approach

    perform_enqueued_jobs do
      Exercise::Approach::Contributorship::Create.(approach, user)
    end

    assert_equal 1, User::ReputationTokens::ExerciseApproachContributionToken.where(user:).count
  end

  test "idempotent" do
    user = create :user
    approach = create :exercise_approach

    assert_idempotent_command do
      Exercise::Approach::Contributorship::Create.(approach, user)
    end

    assert_equal 1, Exercise::Approach::Contributorship.count
  end
end
