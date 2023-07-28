require "test_helper"

class User::ReputationTokens::ExerciseArticleContributionTokenTest < ActiveSupport::TestCase
  test "creates reputation token" do
    user = create :user, handle: "User22", github_username: "user22"
    article = create :exercise_article
    contributorship = create(:exercise_article_contributorship, contributor: user, article:)
    exercise = article.exercise
    track = article.track

    User::ReputationToken::Create.(
      user,
      :exercise_article_contribution,
      contributorship:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::ExerciseArticleContributionToken, rt
    assert_equal "You contributed to the <strong>Performance</strong> article for <strong>Hamming</strong>", rt.text
    assert_equal exercise, rt.exercise
    assert_equal track, rt.track
    assert_equal "#{user.id}|exercise_article_contribution|Article##{article.id}", rt.uniqueness_key
    assert_equal :contributed_to_exercise_article, rt.reason
    assert_equal :authoring, rt.category
    assert_equal 5, rt.value
    assert_equal contributorship.created_at.to_date, rt.earned_on
    assert_equal Exercism::Routes.track_exercise_article_path(track, exercise, article), rt.rendering_data[:internal_url]
  end
end
