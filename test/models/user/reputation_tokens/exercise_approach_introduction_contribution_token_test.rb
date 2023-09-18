require "test_helper"

class User::ReputationTokens::ExerciseApproachIntroductionContributionTokenTest < ActiveSupport::TestCase
  test "creates reputation token" do
    user = create :user, handle: "User22", github_username: "user22"
    exercise = create :practice_exercise
    contributorship = create(:exercise_approach_introduction_contributorship, contributor: user, exercise:)
    track = exercise.track

    User::ReputationToken::Create.(
      user,
      :exercise_approach_introduction_contribution,
      contributorship:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::ExerciseApproachIntroductionContributionToken, rt
    assert_equal "You contributed to the approach of <strong>Bob</strong>", rt.text
    assert_equal exercise, rt.exercise
    assert_equal track, rt.track
    assert_equal "#{user.id}|exercise_approach_introduction_contribution|Exercise##{exercise.id}", rt.uniqueness_key
    assert_equal :contributed_to_exercise_approach_introduction, rt.reason
    assert_equal :authoring, rt.category
    assert_equal 5, rt.value
    assert_equal exercise.created_at.to_date, rt.earned_on
    assert_equal Exercism::Routes.track_exercise_approaches_path(track, exercise), rt.rendering_data[:internal_url]
  end
end
