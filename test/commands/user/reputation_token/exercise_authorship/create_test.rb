require "test_helper"

class User::ReputationToken::ExerciseAuthorship::CreateTest < ActiveSupport::TestCase
  test "creates authorship reputation token" do
    user = create :user, handle: "User22", github_username: "user22"
    authorship = create :exercise_authorship, author: user

    User::ReputationToken::ExerciseAuthorship::Create.(authorship)

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal authorship, rt.context
    assert_equal "authored_exercise/#{authorship.exercise.uuid}", rt.context_key
    assert_equal 'authored_exercise', rt.reason
    assert_equal :authoring, rt.category
    assert_equal 10, rt.value
  end

  test "idempotent" do
    user = create :user, handle: "User22", github_username: "user22"
    authorship = create :exercise_authorship, author: user

    assert_idempotent_command do
      User::ReputationToken::ExerciseAuthorship::Create.(authorship)
    end
  end
end
