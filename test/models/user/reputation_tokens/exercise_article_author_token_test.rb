require "test_helper"

class User::ReputationTokens::ExerciseArticleAuthorTokenTest < ActiveSupport::TestCase
  test "creates reputation token" do
    user = create :user, handle: "User22", github_username: "user22"
    article = create :exercise_article
    authorship = create(:exercise_article_authorship, author: user, article:)
    exercise = article.exercise
    track = article.track

    User::ReputationToken::Create.(
      user,
      :exercise_article_author,
      authorship:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::ExerciseArticleAuthorToken, rt
    assert_equal "You authored the <strong>Performance</strong> article for <strong>Hamming</strong>", rt.text
    assert_equal exercise, rt.exercise
    assert_equal track, rt.track
    assert_equal "#{user.id}|exercise_article_author|Article##{article.id}", rt.uniqueness_key
    assert_equal :authored_exercise_article, rt.reason
    assert_equal :authoring, rt.category
    assert_equal 12, rt.value
    assert_equal authorship.created_at.to_date, rt.earned_on
    assert_equal Exercism::Routes.track_exercise_article_path(track, exercise, article), rt.rendering_data[:internal_url]
  end
end
