require 'test_helper'

class Git::Exercise::ApproachTest < ActiveSupport::TestCase
  test "content" do
    approach = Git::Exercise::Approach.new("performance", "hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))

    puts approach.head_sha
    expected = "wqe"
    assert_equal expected, approach.content
  end

  test "content file path" do
    approach = Git::Exercise::Approach.new("performance", "hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))
    assert_equal('content.md', approach.content_filepath)
  end

  test "content absolute file path" do
    approach = Git::Exercise::Approach.new("performance", "hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))
    assert_equal('exercises/practice/hamming/.approaches/performance/content.md', approach.content_absolute_filepath)
  end

  test "snippet" do
    approach = Git::Exercise::Approach.new("performance", "hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))

    expected = "wqe"
    assert_equal expected, approach.snippet
  end

  test "snippet file path" do
    approach = Git::Exercise::Approach.new("performance", "hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))
    assert_equal('snippet.txt', approach.snippet_filepath)
  end

  test "snippet absolute file path" do
    approach = Git::Exercise::Approach.new("performance", "hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))
    assert_equal('exercises/practice/hamming/.approaches/performance/snippet.txt', approach.snippet_absolute_filepath)
  end
end
