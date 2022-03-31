require "test_helper"

class User::ReputationToken::CreateTest < ActiveSupport::TestCase
  test "triggers reputation period creation on new" do
    user = create :user, handle: "User22", github_username: "user22"
    contributorship = create :exercise_contributorship, contributor: user

    User::ReputationPeriod::MarkForToken.expects(:call)
    AwardBadgeJob.expects(:perform_later).with(user, :contributor)

    2.times do
      User::ReputationToken::Create.(
        user,
        :exercise_contribution, {
          contributorship: contributorship
        }
      )
    end
  end

  test "does not create reputation token for system user" do
    user = create :user, :system
    contributorship = create :exercise_contributorship, contributor: user

    User::ReputationToken::Create.(
      user,
      :exercise_contribution, {
        contributorship: contributorship
      }
    )

    refute User::ReputationToken.exists?
  end

  test "does not create reputation token for ghost user" do
    user = create :user, :ghost
    contributorship = create :exercise_contributorship, contributor: user

    User::ReputationToken::Create.(
      user,
      :exercise_contribution, {
        contributorship: contributorship
      }
    )

    refute User::ReputationToken.exists?
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
