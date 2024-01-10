require "test_helper"

class Track::CreateTest < ActiveSupport::TestCase
  test "creates track" do
    repo_url = TestHelpers.git_repo_url("track")
    Track::CreateForumCategory.stubs(:call)

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
    Track::CreateForumCategory.stubs(:call)

    Track::Create.(TestHelpers.git_repo_url("track"))

    track = Track.last
    assert_equal track.git.concept_exercises.count, track.concept_exercises.count
    assert_equal track.git.practice_exercises.count, track.practice_exercises.count
  end

  test "adds track to forum" do
    Track::CreateForumCategory.expects(:call).once

    Track::Create.(TestHelpers.git_repo_url("track"))
  end

  test "idempotent" do
    Track::CreateForumCategory.stubs(:call)

    assert_idempotent_command do
      Track::Create.(TestHelpers.git_repo_url("track"))
    end
  end
end
