require "test_helper"

class Tracks::ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "index: redirects to dig_deeper" do
    track = create :track
    exercise = create(:practice_exercise, track:)

    get track_exercise_articles_url(track, exercise)

    assert_redirected_to track_exercise_dig_deeper_url(track, exercise)
  end

  test "show: renders correctly for external" do
    track = create :track
    exercise = create(:practice_exercise, track:)
    article = create(:exercise_article, exercise:)

    get track_exercise_article_url(track, exercise, article)

    assert_template "tracks/articles/show"
  end

  test "show: redirects when exercise is hello-world" do
    track = create :track
    exercise = create(:hello_world_exercise, track:)
    article = create(:exercise_article, exercise:)

    get track_exercise_article_url(track, exercise, article)

    assert_redirected_to track_exercise_url(track, exercise)
  end

  test "show: redirects when not iterated and not unlocked help" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    article = create(:exercise_article, exercise:)
    create(:concept_solution, user:, exercise:)

    sign_in!(user)

    get track_exercise_article_url(track, exercise, article)

    assert_redirected_to track_exercise_url(track, exercise)
  end

  test "show: 404s when track does not exist" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    article = create(:exercise_article, exercise:)

    sign_in!(user)

    get track_exercise_article_url('unknown', exercise, article)

    assert_rendered_404
  end

  test "show: 404s when exercise does not exist" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    article = create(:exercise_article, exercise:)

    sign_in!(user)

    get track_exercise_article_url(track, 'unknown', article)

    assert_rendered_404
  end

  test "show: 404s when article does not exist" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)

    sign_in!(user)

    get track_exercise_article_url(track, exercise, 'unknown')

    assert_rendered_404
  end

  test "show: renders when not iterated but unlocked help" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    article = create(:exercise_article, exercise:)
    create :concept_solution, user:, exercise:, unlocked_help: true

    sign_in!(user)

    get track_exercise_article_url(track, exercise, article)

    assert_template "tracks/articles/show"
  end

  test "show: renders when iterated" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)
    exercise = create(:practice_exercise, track:)
    article = create(:exercise_article, exercise:)
    solution = create :concept_solution, user:, exercise:, unlocked_help: true
    create(:iteration, solution:, user:)

    sign_in!(user)

    get track_exercise_article_url(track, exercise, article)

    assert_template "tracks/articles/show"
  end
end
