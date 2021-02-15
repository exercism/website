require "test_helper"

class User::ReputationTokens::ExerciseContributionTokenTest < ActiveSupport::TestCase
  test "creates contributorship reputation token" do
    user = create :user, handle: "User22", github_username: "user22"
    contributorship = create :exercise_contributorship, contributor: user
    exercise = contributorship.exercise
    track = exercise.track

    User::ReputationToken::Create.(
      user,
      :exercise_contribution,
      contributorship: contributorship
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_equal User::ReputationTokens::ExerciseContributionToken, rt.class
    assert_equal "You contributed to <strong>#{exercise.title}</strong>", rt.text
    assert_equal exercise, rt.exercise
    assert_equal track, rt.track
    assert_equal "#{user.id}|exercise_contribution|Exercise##{exercise.id}", rt.uniqueness_key
    assert_equal :contributed_to_exercise, rt.reason
    assert_equal :authoring, rt.category
    assert_equal 5, rt.value
  end
end
