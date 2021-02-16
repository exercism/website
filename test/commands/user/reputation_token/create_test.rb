require "test_helper"

class User::ReputationToken::CreateTest < ActiveSupport::TestCase
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
