require "test_helper"

class Github::Repo::RetrieveTrackIdTest < ActiveSupport::TestCase
  test "track with file repo url" do
    track = create :track, repo_url: "file:///home/erik/exercism/website/test/repos/track"
    assert_equal track.id, Github::Repo::RetrieveTrackId.(track.repo_url)
  end

  test "track with github repo url" do
    track = create :track, repo_url: "https://github.com/exercism/ruby"
    assert_equal track.id, Github::Repo::RetrieveTrackId.(track.repo_url)
  end

  test "track with github repo name" do
    track = create :track, repo_url: "https://github.com/exercism/ruby"
    assert_equal track.id, Github::Repo::RetrieveTrackId.("exercism/ruby")
  end

  %w[test-runner analyzer representer].each do |suffix|
    test "#{suffix} with file repo url" do
      track = create :track, repo_url: "file:///home/erik/exercism/website/test/repos/track"
      assert_equal track.id, Github::Repo::RetrieveTrackId.("#{track.repo_url}-#{suffix}")
    end

    test "#{suffix} with github repo url" do
      track = create :track, repo_url: "https://github.com/exercism/ruby"
      assert_equal track.id, Github::Repo::RetrieveTrackId.("#{track.repo_url}-#{suffix}")
    end

    test "#{suffix} with github repo name" do
      track = create :track, repo_url: "https://github.com/exercism/ruby"
      assert_equal track.id, Github::Repo::RetrieveTrackId.("exercism/ruby-#{suffix}")
    end
  end

  test "no track found" do
    assert_nil Github::Repo::RetrieveTrackId.("exercism/configlet")
  end
end
