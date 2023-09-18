require "test_helper"

class User::ReputationTokens::ExerciseAuthorTokenTest < ActiveSupport::TestCase
  test "creates authorship reputation token" do
    user = create :user, handle: "User22", github_username: "user22"
    authorship = create :exercise_authorship, author: user
    exercise = authorship.exercise
    track = exercise.track

    User::ReputationToken::Create.(
      user,
      :exercise_author,
      authorship:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::ExerciseAuthorToken, rt
    assert_equal "You authored <strong>#{exercise.title}</strong>", rt.text
    assert_equal exercise, rt.exercise
    assert_equal track, rt.track
    assert_equal "#{user.id}|exercise_author|Exercise##{exercise.id}", rt.uniqueness_key
    assert_equal :authored_exercise, rt.reason
    assert_equal :authoring, rt.category
    assert_equal 20, rt.value
    assert_equal exercise.created_at.to_date, rt.earned_on
    assert_equal Exercism::Routes.track_exercise_path(track, exercise), rt.rendering_data[:internal_url]
  end
end
