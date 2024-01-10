require 'test_helper'

class Git::Exercise::ApproachTest < ActiveSupport::TestCase
  test "content" do
    approach = Git::Exercise::Approach.new("readability", "hamming", "practice", create(:track).git)

    assert_equal "# Description\n\nReadability approach", approach.content
  end

  test "content file path" do
    approach = Git::Exercise::Approach.new("readability", "hamming", "practice", create(:track).git)
    assert_equal('content.md', approach.content_filepath)
  end

  test "content absolute file path" do
    approach = Git::Exercise::Approach.new("readability", "hamming", "practice", create(:track).git)
    assert_equal('exercises/practice/hamming/.approaches/readability/content.md', approach.content_absolute_filepath)
  end

  test "snippet" do
    approach = Git::Exercise::Approach.new("readability", "hamming", "practice", create(:track).git)

    assert_equal "READABILITY", approach.snippet
  end

  test "snippet file path" do
    approach = Git::Exercise::Approach.new("readability", "hamming", "practice", create(:track).git)
    assert_equal('snippet.txt', approach.snippet_filepath)
  end

  test "snippet absolute file path" do
    approach = Git::Exercise::Approach.new("readability", "hamming", "practice", create(:track).git)
    assert_equal('exercises/practice/hamming/.approaches/readability/snippet.txt', approach.snippet_absolute_filepath)
  end

  test "snippet with custom extension" do
    approach = Git::Exercise::Approach.new("if", "bob", "practice",
      create(:track, repo_url: TestHelpers.git_repo_url("full-track")).git)

    expected = %{if (IsSilence(message))
      return "Fine. Be that way!";
if (IsQuestion(message))
    return IsYell(message) ? "Calm down, I know what I'm doing!": "Sure.";
if (IsYell(message))
    return "Whoa, chill out!";
return "Whatever.";}
    assert_equal expected, approach.snippet
  end

  test "snippet file path with custom extension" do
    approach = Git::Exercise::Approach.new("if", "bob", "practice",
      create(:track, repo_url: TestHelpers.git_repo_url("full-track")).git)
    assert_equal('snippet.cs', approach.snippet_filepath)
  end

  test "snippet absolute file path with custom extension" do
    approach = Git::Exercise::Approach.new("if", "bob", "practice",
      create(:track, repo_url: TestHelpers.git_repo_url("full-track")).git)
    assert_equal('exercises/practice/bob/.approaches/if/snippet.cs', approach.snippet_absolute_filepath)
  end
end
