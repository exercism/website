require "test_helper"

class ConceptExercise::CreateTest < ActiveSupport::TestCase
  test "creates concept exercise" do
    uuid = SecureRandom.uuid
    track = create :track
    strings = create :track_concept, track: track, slug: 'strings'
    conditionals = create :track_concept, track: track, slug: 'conditionals'
    basics = create :track_concept, track: track, slug: 'basics'

    ConceptExercise::Create.(
      uuid,
      track,
      slug: 'log-levels',
      title: 'Log Levels',
      taught_concepts: [strings],
      prerequisites: [basics, conditionals],
      deprecated: true,
      git_sha: 'HEAD',
      synced_to_git_sha: 'HEAD'
    )

    assert_equal 1, ConceptExercise.count
    ce = ConceptExercise.last

    assert_equal uuid, ce.uuid
    assert_equal track, ce.track
    assert_equal 'log-levels', ce.slug
    assert_equal 'Log Levels', ce.title
    assert_equal [strings], ce.taught_concepts
    assert_equal [conditionals, basics], ce.prerequisites
    assert ce.deprecated
    assert_equal 'HEAD', ce.git_sha
    assert_equal 'HEAD', ce.synced_to_git_sha
  end

  test "idempotent" do
    uuid = SecureRandom.uuid
    track = create :track
    strings = create :track_concept, track: track, slug: 'strings'
    conditionals = create :track_concept, track: track, slug: 'conditionals'
    basics = create :track_concept, track: track, slug: 'basics'

    assert_idempotent_command do
      ConceptExercise::Create.(
        uuid,
        track,
        slug: 'log-levels',
        title: 'Log Levels',
        taught_concepts: [strings],
        prerequisites: [basics, conditionals],
        deprecated: true,
        git_sha: 'HEAD',
        synced_to_git_sha: 'HEAD'
      )
    end
  end
end
