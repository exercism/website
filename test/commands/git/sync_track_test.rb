require "test_helper"

class Git::SyncTrackTest < ActiveSupport::TestCase
  test "no change when git SHA matches HEAD SHA" do
    track = create :track, slug: 'fsharp', active: true, git_sha: "HEAD"

    Git::SyncTrack.(track)

    refute track.changed?
  end

  test "no change when there are no track changes in the diff" do
    track = create :track, slug: 'fsharp', active: true, git_sha: "765f921ce85917cfe22b2a608d370f67da57820b"

    Git::SyncTrack.(track)

    refute track.changed?
  end

  test "git SHA changes to HEAD SHA when there are changes" do
    track = create :track, slug: "fsharp",
                           title: "F#!",
                           active: false,
                           blurb: "F# is a strongly-typed, functional language that is part of Microsoft's .NET language stack. F# can elegantly handle almost every problem you throw at it.", # rubocop:disable Layout/LineLength
                           git_sha: "f290a29144b93b21e2399cd532b22562d83b6a52"

    Git::SyncTrack.(track)

    assert_equal "70a8473aa074c1ee9c843665347481fe5c8ee95f", track.git_sha
  end

  test "track is updated when there are changes" do
    track = create :track, slug: "fsharp",
                           title: "F#!",
                           active: false,
                           blurb: "F# is a strongly-typed, functional language that is part of Microsoft's .NET language stack. F# can elegantly handle almost every problem you throw at it.", # rubocop:disable Layout/LineLength
                           git_sha: "f290a29144b93b21e2399cd532b22562d83b6a52"

    Git::SyncTrack.(track)

    assert_equal "F#", track.title
    assert track.active
    assert_equal "F# is a strongly-typed, functional language that is part of Microsoft's .NET language stack. Although F# is great for data science problems, it can elegantly handle almost every problem you throw at it.", track.blurb # rubocop:disable Layout/LineLength
  end
end
