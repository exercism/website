require 'test_helper'

class Git::RepresenterTest < ActiveSupport::TestCase
  test "passing_repo_works" do
    repo = Git::Repository.new(repo_url: TestHelpers.git_repo_url("track-representer"))
    representer = Git::Representer.new(repo:)
    assert_equal 2, representer.version
  end

  test "passing_repo_url_works" do
    representer = Git::Representer.new(repo_url: TestHelpers.git_repo_url("track-representer"))
    assert_equal 2, representer.version
  end

  test "passing_both_repo_and_repo_url_raises" do
    assert_raises do
      Git::Representer.new(repo_url: "foobar", repo: "barfoo")
    end
  end

  test "version" do
    representer = Git::Representer.new(repo_url: TestHelpers.git_repo_url("track-representer"))
    assert_equal 2, representer.version
  end
end
