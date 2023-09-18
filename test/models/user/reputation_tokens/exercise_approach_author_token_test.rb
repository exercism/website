require "test_helper"

class User::ReputationTokens::ExerciseApproachAuthorTokenTest < ActiveSupport::TestCase
  test "creates reputation token" do
    user = create :user, handle: "User22", github_username: "user22"
    approach = create :exercise_approach
    authorship = create(:exercise_approach_authorship, author: user, approach:)
    exercise = approach.exercise
    track = approach.track

    User::ReputationToken::Create.(
      user,
      :exercise_approach_author,
      authorship:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::ExerciseApproachAuthorToken, rt
    assert_equal "You authored the <strong>Readability</strong> approach of <strong>Hamming</strong>", rt.text
    assert_equal exercise, rt.exercise
    assert_equal track, rt.track
    assert_equal "#{user.id}|exercise_approach_author|Approach##{approach.id}", rt.uniqueness_key
    assert_equal :authored_exercise_approach, rt.reason
    assert_equal :authoring, rt.category
    assert_equal 12, rt.value
    assert_equal authorship.created_at.to_date, rt.earned_on
    assert_equal Exercism::Routes.track_exercise_approach_path(track, exercise, approach), rt.rendering_data[:internal_url]
  end
end
