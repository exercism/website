require "test_helper"

class User::ReputationTokens::ExerciseApproachContributionTokenTest < ActiveSupport::TestCase
  test "creates reputation token" do
    user = create :user, handle: "User22", github_username: "user22"
    approach = create :exercise_approach
    contributorship = create(:exercise_approach_contributorship, contributor: user, approach:)
    exercise = approach.exercise
    track = approach.track

    User::ReputationToken::Create.(
      user,
      :exercise_approach_contribution,
      contributorship:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::ExerciseApproachContributionToken, rt
    assert_equal "You contributed to the <strong>Readability</strong> approach of <strong>Hamming</strong>", rt.text
    assert_equal exercise, rt.exercise
    assert_equal track, rt.track
    assert_equal "#{user.id}|exercise_approach_contribution|Approach##{approach.id}", rt.uniqueness_key
    assert_equal :contributed_to_exercise_approach, rt.reason
    assert_equal :authoring, rt.category
    assert_equal 5, rt.value
    assert_equal contributorship.created_at.to_date, rt.earned_on
    assert_equal Exercism::Routes.track_exercise_approach_path(track, exercise, approach), rt.rendering_data[:internal_url]
  end
end
