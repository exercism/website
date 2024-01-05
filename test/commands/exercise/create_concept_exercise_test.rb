require "test_helper"

class Exercise::CreateConceptExerciseTest < ActiveSupport::TestCase
  test "creates concept exercise" do
    uuid = SecureRandom.uuid
    track = create :track
    strings = create :concept, track:, slug: 'strings'
    conditionals = create :concept, track:, slug: 'conditionals'
    basics = create :concept, track:, slug: 'basics'

    Exercise::CreateConceptExercise.(
      uuid,
      track,
      slug: 'log-levels',
      title: 'Log Levels',
      blurb: 'Learn about strings by processing logs',
      icon_name: 'logs',
      position: 1,
      taught_concepts: [strings],
      prerequisites: [basics, conditionals],
      status: :active,
      git_sha: 'HEAD',
      synced_to_git_sha: 'HEAD'
    )

    assert_equal 1, ConceptExercise.count
    ce = ConceptExercise.last

    assert_equal uuid, ce.uuid
    assert_equal track, ce.track
    assert_equal 'log-levels', ce.slug
    assert_equal 'Log Levels', ce.title
    assert_equal 'logs', ce.icon_name
    assert_equal [strings], ce.taught_concepts
    assert_equal [conditionals, basics], ce.prerequisites
    assert_equal :active, ce.status
    assert_equal 'HEAD', ce.git_sha
    assert_equal 'HEAD', ce.synced_to_git_sha
  end

  test "idempotent" do
    uuid = SecureRandom.uuid
    track = create :track
    strings = create :concept, track:, slug: 'strings'
    conditionals = create :concept, track:, slug: 'conditionals'
    basics = create :concept, track:, slug: 'basics'

    assert_idempotent_command do
      Exercise::CreateConceptExercise.(
        uuid,
        track,
        slug: 'log-levels',
        title: 'Log Levels',
        blurb: 'Learn about strings by processing logs',
        icon_name: 'logs',
        position: 1,
        taught_concepts: [strings],
        prerequisites: [basics, conditionals],
        status: :active,
        git_sha: 'HEAD',
        synced_to_git_sha: 'HEAD'
      )
    end

    assert_equal 1, SiteUpdate.count
  end

  test "creates site_update" do
    SiteUpdates::ProcessNewExerciseUpdate.expects(:call)

    Exercise::CreateConceptExercise.(
      SecureRandom.uuid,
      create(:track),
      **build(:concept_exercise).attributes.symbolize_keys
    )
  end
end
