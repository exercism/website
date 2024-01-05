require "test_helper"

class Exercise::CreatePracticeExerciseTest < ActiveSupport::TestCase
  test "creates practice exercise" do
    uuid = SecureRandom.uuid
    track = create :track
    conditionals = create :concept, track:, slug: 'conditionals'
    basics = create :concept, track:, slug: 'basics'

    Exercise::CreatePracticeExercise.(
      uuid,
      track,
      slug: 'anagram',
      title: 'Anagram',
      blurb: 'Annie',
      icon_name: 'anagram',
      position: 1,
      prerequisites: [basics, conditionals],
      status: :active,
      git_sha: 'HEAD',
      synced_to_git_sha: 'HEAD'
    )

    assert_equal 1, PracticeExercise.count
    pe = PracticeExercise.last

    assert_equal uuid, pe.uuid
    assert_equal track, pe.track
    assert_equal 'anagram', pe.slug
    assert_equal 'Anagram', pe.title
    assert_equal 'anagram', pe.icon_name
    assert_equal [conditionals, basics], pe.prerequisites
    assert_equal :active, pe.status
    assert_equal 'HEAD', pe.git_sha
    assert_equal 'HEAD', pe.synced_to_git_sha
  end

  test "idempotent" do
    uuid = SecureRandom.uuid
    track = create :track
    conditionals = create :concept, track:, slug: 'conditionals'
    basics = create :concept, track:, slug: 'basics'

    assert_idempotent_command do
      Exercise::CreatePracticeExercise.(
        uuid,
        track,
        slug: 'anagram',
        title: 'Anagram',
        blurb: 'Annie',
        icon_name: 'anagram',
        position: 1,
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

    Exercise::CreatePracticeExercise.(
      SecureRandom.uuid,
      create(:track),
      **build(:practice_exercise).attributes.symbolize_keys
    )
  end
end
