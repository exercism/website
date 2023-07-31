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
      contributorship:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::ExerciseContributionToken, rt
    assert_equal "You contributed to <strong>#{exercise.title}</strong>", rt.text
    assert_equal exercise, rt.exercise
    assert_equal track, rt.track
    assert_equal "#{user.id}|exercise_contribution|Exercise##{exercise.id}", rt.uniqueness_key
    assert_equal :contributed_to_exercise, rt.reason
    assert_equal :authoring, rt.category
    assert_equal 10, rt.value
    assert_equal exercise.created_at.to_date, rt.earned_on
    assert_equal Exercism::Routes.track_exercise_path(track, exercise), rt.rendering_data[:internal_url]
  end
end
