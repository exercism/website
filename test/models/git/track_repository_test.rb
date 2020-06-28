require 'test_helper'

class Git::TrackTest < ActiveSupport::TestCase
  test "Retrieves test_regexp" do
    track = Git::Track.new(TestHelpers.git_repo_url("track-with-exercises"))
    assert_equal(/test/, track.test_regexp)
  end

  test "Has correct default test_regexp" do
    track = Git::Track.new(TestHelpers.git_repo_url("track-naked"))
    assert_equal(/[tT]est/, track.test_regexp)
  end

  test "Retrieves ignore_regexp" do
    track = Git::Track.new(TestHelpers.git_repo_url("track-with-exercises"))
    assert_equal(/[iI]gno/, track.ignore_regexp)
  end

  test "Has correct default ignore_regexp" do
    track = Git::Track.new(TestHelpers.git_repo_url("track-naked"))
    assert_equal(/[iI]gnore/, track.ignore_regexp)
  end
end
