require 'test_helper'

class Git::Exercise::ArticleTest < ActiveSupport::TestCase
  test "content" do
    article = Git::Exercise::Article.new("performance", "hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track"))

    assert_equal "# Description\n\nPerformance article", article.content
  end

  test "content file path" do
    article = Git::Exercise::Article.new("performance", "hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track"))
    assert_equal('content.md', article.content_filepath)
  end

  test "content absolute file path" do
    article = Git::Exercise::Article.new("performance", "hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track"))
    assert_equal('exercises/practice/hamming/.articles/performance/content.md', article.content_absolute_filepath)
  end

  test "snippet" do
    article = Git::Exercise::Article.new("performance", "hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track"))

    assert_equal "PERFORMANCE", article.snippet
  end

  test "snippet file path" do
    article = Git::Exercise::Article.new("performance", "hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track"))
    assert_equal('snippet.md', article.snippet_filepath)
  end

  test "snippet absolute file path" do
    article = Git::Exercise::Article.new("performance", "hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track"))
    assert_equal('exercises/practice/hamming/.articles/performance/snippet.md', article.snippet_absolute_filepath)
  end
end
