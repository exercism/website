require "test_helper"

class PracticeExercise::CreateTest < ActiveSupport::TestCase
  test "creates practice exercise" do
    uuid = SecureRandom.uuid
    track = create :track
    conditionals = create :track_concept, track: track, slug: 'conditionals'
    basics = create :track_concept, track: track, slug: 'basics'

    PracticeExercise::Create.(
      uuid,
      track,
      slug: 'anagram',
      title: 'Anagram',
      prerequisites: [basics, conditionals],
      deprecated: true,
      git_sha: 'HEAD',
      synced_to_git_sha: 'HEAD'
    )

    assert_equal 1, PracticeExercise.count
    pe = PracticeExercise.last

    assert_equal uuid, pe.uuid
    assert_equal track, pe.track
    assert_equal 'anagram', pe.slug
    assert_equal 'Anagram', pe.title
    assert_equal [conditionals, basics], pe.prerequisites
    assert pe.deprecated
    assert_equal 'HEAD', pe.git_sha
    assert_equal 'HEAD', pe.synced_to_git_sha
  end

  test "idempotent" do
    uuid = SecureRandom.uuid
    track = create :track
    conditionals = create :track_concept, track: track, slug: 'conditionals'
    basics = create :track_concept, track: track, slug: 'basics'

    assert_idempotent_command do
      PracticeExercise::Create.(
        uuid,
        track,
        slug: 'anagram',
        title: 'Anagram',
        prerequisites: [basics, conditionals],
        deprecated: true,
        git_sha: 'HEAD',
        synced_to_git_sha: 'HEAD'
      )
    end
  end
end
