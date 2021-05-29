require "test_helper"

class User::ReputationToken::CreateTest < ActiveSupport::TestCase
  test "triggers reputation period creation on new" do
    user = create :user, handle: "User22", github_username: "user22"
    contributorship = create :exercise_contributorship, contributor: user

    User::ReputationPeriod::MarkForNewToken.expects(:call).once

    2.times do
      User::ReputationToken::Create.(
        user,
        :exercise_contribution, {
          contributorship: contributorship
        }
      )
    end
  end

  test "idempotent" do
    user = create :user, handle: "User22", github_username: "user22"
    contributorship = create :exercise_contributorship, contributor: user

    assert_idempotent_command do
      User::ReputationToken::Create.(
        user,
        :exercise_contribution, {
          contributorship: contributorship
        }
      )
    end
  end
end
