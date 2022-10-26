require "test_helper"

class Track::CreateTest < ActiveSupport::TestCase
  test "creates track" do
    repo_url = TestHelpers.git_repo_url("track-with-exercises")
    Forum::CreateTrackCategory.stubs(:call)

    Track::Create.(repo_url)

    assert_equal 1, Track.count
    track = Track.last

    assert_equal 'ruby', track.slug
    assert_equal 'Ruby', track.title
    assert_equal 'Ruby is a dynamic, open source programming language with a focus on simplicity and productivity.', track.blurb
    assert_equal repo_url, track.repo_url
    assert_equal track.git.head_sha, track.synced_to_git_sha
    expected_tags = %w[execution_mode/interpreted platform/windows platform/linux platform/mac paradigm/declarative
                       paradigm/object_oriented]
    assert_equal expected_tags, track.tags
  end

  test "syncs track" do
    Forum::CreateTrackCategory.stubs(:call)

    Track::Create.(TestHelpers.git_repo_url("track-with-exercises"))

    track = Track.last
    assert_equal track.git.concept_exercises.count, track.concept_exercises.count
    assert_equal track.git.practice_exercises.count, track.practice_exercises.count
  end

  test "creates contributor team if track does not exist" do
    Forum::CreateTrackCategory.stubs(:call)

    track = Track::Create.(TestHelpers.git_repo_url("track-with-exercises"))

    assert_equal 1, ContributorTeam.count
    team = ContributorTeam.last
    assert_equal 'ruby', team.github_name
    assert_equal :track_maintainers, team.type
    assert_equal track, team.track
  end

  test "does not create contributor team if track already exists" do
    track = create :track, slug: 'ruby'
    team = create :contributor_team, github_name: 'ruby', track: track
    updated_at_before_create = team.updated_at

    Track::Create.(TestHelpers.git_repo_url("track-with-exercises"))

    assert_equal updated_at_before_create, team.reload.updated_at
  end

  test "adds track to forum" do
    Forum::CreateTrackCategory.expects(:call).once

    Track::Create.(TestHelpers.git_repo_url("track-with-exercises"))
  end

  test "idempotent" do
    Forum::CreateTrackCategory.stubs(:call)

    assert_idempotent_command do
      Track::Create.(TestHelpers.git_repo_url("track-with-exercises"))
    end
  end
end
