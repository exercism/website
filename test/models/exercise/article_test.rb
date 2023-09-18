require "test_helper"

class Exercise::ArticleTest < ActiveSupport::TestCase
  test "exercise wired in correctly" do
    exercise = create :practice_exercise

    article = create(:exercise_article, exercise:)
    assert_equal exercise, article.exercise
    assert_equal [article], exercise.articles
  end

  test "authors wired in correctly" do
    author_1 = create :user
    author_2 = create :user

    article = create :exercise_article
    create :exercise_article_authorship, article:, author: author_1
    create :exercise_article_authorship, article:, author: author_2

    assert_equal [author_1, author_2], article.authors
    assert_equal [article], author_1.authored_articles
    assert_equal [article], author_2.authored_articles
  end

  test "contributors wired in correctly" do
    contributor_1 = create :user
    contributor_2 = create :user

    article = create :exercise_article
    create :exercise_article_contributorship, article:, contributor: contributor_1
    create :exercise_article_contributorship, article:, contributor: contributor_2

    assert_equal [contributor_1, contributor_2], article.contributors
    assert_equal [article], contributor_1.contributed_articles
    assert_equal [article], contributor_2.contributed_articles
  end

  test "content" do
    exercise = create :practice_exercise, slug: 'hamming'
    article = create(:exercise_article, exercise:)

    assert_equal "# Description\n\nPerformance article", article.content
  end

  test "content_html" do
    exercise = create :practice_exercise, slug: 'hamming'
    article = create(:exercise_article, exercise:)

    assert_equal "<p>Performance article</p>\n", article.content_html
  end

  test "snippet" do
    exercise = create :practice_exercise, slug: 'hamming'
    article = create(:exercise_article, exercise:)

    assert_equal "PERFORMANCE", article.snippet
  end

  test "snippet_html" do
    exercise = create :practice_exercise, slug: 'hamming'
    article = create(:exercise_article, exercise:)

    assert_equal "<p>PERFORMANCE</p>\n", article.snippet_html
  end
end
