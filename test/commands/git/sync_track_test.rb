require "test_helper"

class Git::SyncTrackTest < ActiveSupport::TestCase
  test "no change when git sync SHA matches HEAD SHA" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: "HEAD"

    Git::SyncTrack.(track)

    refute track.changed?
  end

  test "git sync SHA changes to HEAD SHA when there are no changes" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: "765f921ce85917cfe22b2a608d370f67da57820b"

    Git::SyncTrack.(track)

    git_track = Git::Track.new(track.slug, repo_url: track.repo_url)
    assert_equal git_track.head_sha, track.synced_to_git_sha
  end

  test "git sync SHA changes to HEAD SHA when there are changes" do
    track = create :track, slug: 'fsharp', active: false, synced_to_git_sha: "f290a29144b93b21e2399cd532b22562d83b6a52"

    Git::SyncTrack.(track)

    git_track = Git::Track.new(track.slug, repo_url: track.repo_url)
    assert_equal git_track.head_sha, track.synced_to_git_sha
  end

  test "track is updated when there are changes" do
    track = create :track, slug: "fsharp",
                           title: "F#!",
                           active: false,
                           blurb: "F# is a strongly-typed, functional language that is part of Microsoft's .NET language stack. F# can elegantly handle almost every problem you throw at it.", # rubocop:disable Layout/LineLength
                           synced_to_git_sha: "f290a29144b93b21e2399cd532b22562d83b6a52"

    Git::SyncTrack.(track)

    assert_equal "F#", track.title
    assert track.active
    assert_equal "F# is a strongly-typed, functional language that is part of Microsoft's .NET language stack. Although F# is great for data science problems, it can elegantly handle almost every problem you throw at it.", track.blurb # rubocop:disable Layout/LineLength
  end

  test "adds new concepts defined in config.json" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: 'c68f057eb4cfc3f9d07867e9ee9e29de7bfac088'

    Git::SyncTrack.(track)

    numbers = ::Track::Concept.find_by(uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3')
    assert_includes track.concepts, numbers
  end

  test "removes concepts that are not in config.json" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: 'c68f057eb4cfc3f9d07867e9ee9e29de7bfac088'
    recursion = create :track_concept, track: track, slug: 'recursion', uuid: 'f1b9f00d-12e7-49b8-b315-e2f4b2d875f1'

    Git::SyncTrack.(track)

    refute_includes track.concepts, recursion
  end

  test "adds new concept exercises defined in config.json" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: 'c68f057eb4cfc3f9d07867e9ee9e29de7bfac088'

    Git::SyncTrack.(track)

    cars_assemble = ::Track::ConceptExercise.find_by(uuid: '6ea2765e-5885-11ea-82b4-0242ac130003')
    assert_includes track.concept_exercises, cars_assemble
  end

  test "adds new practice exercises defined in config.json" do
    track = create :track, slug: 'fsharp', synced_to_git_sha: '171577814bd42a0ed0880b9c28016b26688c51ab'

    Git::SyncTrack.(track)

    two_fer = ::Track::ConceptExercise.find_by(uuid: 'two-fer')
    assert_includes track.practice_exercises, two_fer
  end
end
