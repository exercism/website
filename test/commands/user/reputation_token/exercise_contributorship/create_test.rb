require "test_helper"

class User::ReputationToken::ExerciseContributorship::CreateTest < ActiveSupport::TestCase
  test "creates contributorship reputation token" do
    user = create :user, handle: "User22", github_username: "user22"
    contributorship = create :exercise_contributorship, contributor: user

    User::ReputationToken::ExerciseContributorship::Create.(contributorship)

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal contributorship, rt.context
    assert_equal "contributed_to_exercise/#{contributorship.exercise.uuid}", rt.context_key
    assert_equal 'contributed_to_exercise', rt.reason
    assert_equal :authoring, rt.category
    assert_equal 5, rt.value
  end

  test "idempotent" do
    user = create :user, handle: "User22", github_username: "user22"
    contributorship = create :exercise_contributorship, contributor: user

    assert_idempotent_command do
      User::ReputationToken::ExerciseContributorship::Create.(contributorship)
    end
  end
end
