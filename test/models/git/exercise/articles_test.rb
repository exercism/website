require 'test_helper'

class Git::Exercise::ArticlesTest < ActiveSupport::TestCase
  test "articles" do
    git_articles = Git::Exercise::Articles.new("hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track"))

    expected = [
      {
        uuid: "7feff49c-32ea-4d30-b6da-002b51e0f57d",
        slug: "performance",
        title: "Performance",
        blurb: "Check out this perf!",
        authors: ["erikschierboom"],
        contributors: ["ihid"]
      }
    ]
    assert_equal expected, git_articles.articles
  end

  test "filepaths" do
    git_articles = Git::Exercise::Articles.new("hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track"))

    expected_filepaths = [
      "config.json",
      "performance/content.md",
      "performance/snippet.md"
    ]
    assert_equal expected_filepaths, git_articles.filepaths
  end

  test "absolute_filepaths" do
    git_articles = Git::Exercise::Articles.new("hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track"))

    expected_filepaths = [
      "exercises/practice/hamming/.articles/config.json",
      "exercises/practice/hamming/.articles/performance/content.md",
      "exercises/practice/hamming/.articles/performance/snippet.md"
    ]
    assert_equal expected_filepaths, git_articles.absolute_filepaths
  end

  test "config file path" do
    git_articles = Git::Exercise::Articles.new("hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track"))
    assert_equal('config.json', git_articles.config_filepath)
  end

  test "config absolute file path" do
    git_articles = Git::Exercise::Articles.new("hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track"))
    assert_equal('exercises/practice/hamming/.articles/config.json', git_articles.config_absolute_filepath)
  end
end
