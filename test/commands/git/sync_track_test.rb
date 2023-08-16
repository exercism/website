require "test_helper"

class Git::SyncTrackTest < ActiveSupport::TestCase
  # test "no change when git sync SHA matches HEAD SHA" do
  #   track = create :track, synced_to_git_sha: "HEAD"

  #   Git::SyncConcept.expects(:call).never
  #   Git::SyncConceptExercise.expects(:call).never
  #   Git::SyncPracticeExercise.expects(:call).never
  #   Git::SyncTrack.(track)

  #   refute track.changed?
  # end

  test "resyncs when force_sync is passed" do
    track = create :track, synced_to_git_sha: "HEAD"

    Git::SyncConcept.expects(:call).with(anything, force_sync: true).at_least_once
    Git::SyncConceptExercise.expects(:call).with(anything, force_sync: true).at_least_once
    Git::SyncPracticeExercise.expects(:call).with(anything, force_sync: true).at_least_once

    Git::SyncTrack.(track, force_sync: true)

    refute track.changed?
  end

  test "git sync SHA changes to HEAD SHA when there are no changes" do
    track = create :track, synced_to_git_sha: "3a2874df76154e356644425954c76b2a4c343b40"

    Git::SyncTrack.(track)

    git_track = Git::Track.new(repo_url: track.repo_url)
    assert_equal git_track.head_sha, track.synced_to_git_sha
  end

  test "git sync SHA changes to HEAD SHA when there are changes" do
    track = create :track, active: true, synced_to_git_sha: "aad630acfbbdef16d90105a205b957c138fa1b93"

    Git::SyncTrack.(track)

    git_track = Git::Track.new(repo_url: track.repo_url)
    assert_equal git_track.head_sha, track.synced_to_git_sha
  end

  test "git sync SHA does not change when concept syncing fails" do
    track = create :track, active: true, synced_to_git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a"
    Git::SyncConcept.expects(:call).raises(RuntimeError)
    Github::Issue::OpenForTrackSyncFailure.stubs(:call)

    Git::SyncTrack.(track)

    assert_equal "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", track.synced_to_git_sha
  end

  test "git sync SHA does not change when concept exercise syncing fails" do
    track = create :track, active: true, synced_to_git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a"
    Git::SyncConceptExercise.expects(:call).raises(RuntimeError)
    Github::Issue::OpenForTrackSyncFailure.stubs(:call)

    Git::SyncTrack.(track)

    assert_equal "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", track.synced_to_git_sha
  end

  test "git sync SHA does not change when practice exercise syncing fails" do
    track = create :track, active: true, synced_to_git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a"
    Git::SyncPracticeExercise.expects(:call).raises(RuntimeError)
    Github::Issue::OpenForTrackSyncFailure.stubs(:call)

    Git::SyncTrack.(track)

    assert_equal "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", track.synced_to_git_sha
  end

  test "track is updated when there are changes" do
    track = create :track, slug: "ruby",
      title: "Ruby",
      active: true,
      blurb: "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write.", # rubocop:disable Layout/LineLength
      synced_to_git_sha: "aad630acfbbdef16d90105a205b957c138fa1b93"

    Git::SyncTrack.(track)

    assert_equal "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity.", track.blurb
  end

  test "track is updated when tags change" do
    track = create :track, slug: "fsharp",
      title: "F#",
      active: true,
      blurb: "F# is a strongly-typed, functional language that is part of Microsoft's .NET language stack. Although F# is great for data science problems, it can elegantly handle almost every problem you throw at it.", # rubocop:disable Layout/LineLength
      tags: ["execution_mode/interpreted", "platform/windows", "platform/linux", "paradigm/declarative", "paradigm/object_oriented"],
      synced_to_git_sha: "0ec511318983b7d27d6a27410509071ee7683e52"

    Git::SyncTrack.(track)

    expected = [
      "execution_mode/interpreted",
      "platform/windows",
      "platform/linux",
      "platform/mac",
      "paradigm/declarative",
      "paradigm/object_oriented"
    ]
    assert_equal expected, track.tags
  end

  test "adds new concepts defined in config.json" do
    track = create :track, synced_to_git_sha: 'e9086c7c5c9f005bbab401062fa3b2f501ecac24'

    assert_empty track.concepts

    Git::SyncTrack.(track)

    assert_equal 10, track.concepts.length
  end

  test "concept exercises use position from config" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'

    Git::SyncTrack.(track)

    actual_order = track.concept_exercises.order(:position).pluck(:slug)
    expected_order = %w[arrays booleans lasagna log-levels numbers strings]
    assert_equal expected_order, actual_order
  end

  test "practice exercises use position from config" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'

    Git::SyncTrack.(track)

    actual_order = track.practice_exercises.order(:position).pluck(:slug)
    expected_order = %w[hello-world allergies anagram bob hamming isogram leap satellite space-age tournament]
    assert_equal expected_order, actual_order
  end

  test "first position is for hello-world exercise, followed by concept exercises and then practice exercises" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'

    Git::SyncTrack.(track)

    actual_order = track.exercises.order(:position).pluck(:slug)
    expected_order = %w[
      hello-world
      arrays booleans lasagna log-levels numbers strings allergies
      anagram bob hamming isogram leap satellite space-age tournament
    ]
    assert_equal expected_order, actual_order
  end

  test "concept exercises use track concepts for taught concepts" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    track_concept = create :concept, track:, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    other_track = create :track, slug: 'fsharp'
    other_track_concept = create :concept, track: other_track, slug: 'basics'

    Git::SyncTrack.(track)

    track_concept_exercise = track.concept_exercises.find_by(uuid: '71ae39c4-7364-11ea-bc55-0242ac130003')
    assert_includes track_concept_exercise.taught_concepts, track_concept
    refute_includes track_concept_exercise.taught_concepts, other_track_concept
  end

  test "concept exercises use newly created track concepts for taught concepts" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'

    Git::SyncTrack.(track)

    track_concept_exercise = track.concept_exercises.find_by(uuid: '71ae39c4-7364-11ea-bc55-0242ac130003')
    assert_equal 1, track_concept_exercise.taught_concepts.count
  end

  test "concept exercises use track concepts for prerequisites" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    track_concept = create :concept, track:, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    other_track = create :track, slug: 'fsharp'
    other_track_concept = create :concept, track: other_track, slug: 'basics'

    Git::SyncTrack.(track)

    track_concept_exercise = track.concept_exercises.find_by(uuid: 'e5476046-5289-11ea-8d77-2e728ce88125')
    assert_includes track_concept_exercise.prerequisites, track_concept
    refute_includes track_concept_exercise.prerequisites, other_track_concept
  end

  test "practice exercises use track concepts for prerequisites" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    track_concept = create :concept, track:, slug: 'conditionals', uuid: 'dedd9182-66b7-4fbc-bf4b-ba6603edbfca'
    other_track = create :track, slug: 'fsharp'
    other_track_concept = create :concept, track: other_track, slug: 'conditionals'

    Git::SyncTrack.(track)

    track_practice_exercise = track.practice_exercises.find_by(uuid: '4f12ede3-312e-482a-b0ae-dfd29f10b5fb')
    assert_includes track_practice_exercise.prerequisites, track_concept
    refute_includes track_practice_exercise.prerequisites, other_track_concept
  end

  test "practice exercises use track concepts for practiced concepts" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    track_concept = create :concept, track:, slug: 'time', uuid: '4055d823-e100-4a46-89d3-dcb01dd6043f'
    other_track = create :track, slug: 'fsharp'
    other_track_concept = create :concept, track: other_track, slug: 'time'

    Git::SyncTrack.(track)

    track_practice_exercise = track.practice_exercises.find_by(uuid: 'a0acb1ec-43cb-4c65-a279-6c165eb79206')
    assert_includes track_practice_exercise.practiced_concepts, track_concept
    refute_includes track_practice_exercise.practiced_concepts, other_track_concept
  end

  test "adds new concept exercises defined in config.json" do
    track = create :track, synced_to_git_sha: 'e9086c7c5c9f005bbab401062fa3b2f501ecac24'

    assert_empty track.concept_exercises

    Git::SyncTrack.(track)

    assert_equal 6, track.concept_exercises.length
  end

  test "adds new practice exercises defined in config.json" do
    track = create :track, synced_to_git_sha: 'c4701190aa99d47b7e92e5c1605659a4f08d6776'

    assert_empty track.practice_exercises

    Git::SyncTrack.(track)

    assert_equal 10, track.practice_exercises.length
  end

  test "syncs all concepts" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'

    Git::SyncTrack.(track)

    assert_equal 10, track.concepts.length
    track.concepts.each do |concept|
      assert_equal track.git.head_sha, concept.synced_to_git_sha
    end
  end

  test "syncs all concept exercises" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'

    Git::SyncTrack.(track)

    assert_equal 6, track.concept_exercises.length
    track.concept_exercises.each do |concept_exercise|
      assert_equal track.git.head_sha, concept_exercise.synced_to_git_sha
    end
  end

  test "syncs all practice exercises" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'

    Git::SyncTrack.(track)

    assert_equal 10, track.practice_exercises.length
    track.practice_exercises.each do |practice_exercise|
      assert_equal track.git.head_sha, practice_exercise.synced_to_git_sha
    end
  end

  test "syncs with nil concepts" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    git_track = Git::Track.new("HEAD", repo_url: track.repo_url)
    config = git_track.config
    config[:concepts] = nil

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    Git::SyncTrack.(track)

    assert_empty track.concepts
  end

  test "syncs with nil concept exercises" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    git_track = Git::Track.new("HEAD", repo_url: track.repo_url)
    config = git_track.config
    config[:exercises][:concept] = nil

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    Git::SyncTrack.(track)

    assert_empty track.concept_exercises
  end

  test "syncs with nil practice exercises" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    git_track = Git::Track.new("HEAD", repo_url: track.repo_url)
    config = git_track.config
    config[:exercises][:practice] = nil

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    Git::SyncTrack.(track)

    assert_empty track.practice_exercises
  end

  test "syncs concept exercises with nil concepts" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    git_track = Git::Track.new("HEAD", repo_url: track.repo_url)
    config = git_track.config
    config[:exercises][:concept].each { |exercise| exercise[:concepts] = nil }

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    Git::SyncTrack.(track)

    assert_equal 6, track.concept_exercises.length
  end

  test "syncs concept exercises with nil prerequisites" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    git_track = Git::Track.new("HEAD", repo_url: track.repo_url)
    config = git_track.config
    config[:exercises][:concept].each { |exercise| exercise[:prerequisites] = nil }

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    Git::SyncTrack.(track)

    assert_equal 6, track.concept_exercises.length
  end

  test "syncs practice exercises with nil prerequisites" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    git_track = Git::Track.new("HEAD", repo_url: track.repo_url)
    config = git_track.config
    config[:exercises][:practice].each { |exercise| exercise[:prerequisites] = nil }

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    Git::SyncTrack.(track)

    assert_equal 10, track.practice_exercises.length
  end

  test "syncs practice exercises with nil practices" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    git_track = Git::Track.new("HEAD", repo_url: track.repo_url)
    config = git_track.config
    config[:exercises][:practice].each { |exercise| exercise[:practices] = nil }

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    Git::SyncTrack.(track)

    assert_equal 10, track.practice_exercises.length
  end

  test "ignores concept exercise prerequisites with no concept exercise unlocking them" do
    track = create :track, synced_to_git_sha: 'cb075456495cc4c2910ca86148024f232c659ceb'
    types = create :concept, track:, slug: 'types', uuid: '3f1168b5-fc74-4586-94f5-20e4f60e52cf'

    Git::SyncTrack.(track)

    exercise = track.concept_exercises.find_by(uuid: '06ea7869-4907-454d-a5e5-9d5b71098b17')
    refute_includes exercise.prerequisites, types
  end

  test "ignores practice exercise prerequisites with no concept exercise unlocking them" do
    track = create :track, synced_to_git_sha: 'cb075456495cc4c2910ca86148024f232c659ceb'
    types = create :concept, track:, slug: 'types', uuid: '3f1168b5-fc74-4586-94f5-20e4f60e52cf'
    dates = create :concept, track:, slug: 'dates', uuid: '091f10d6-99aa-47f4-9eff-0e62eddbee7a'

    Git::SyncTrack.(track)

    exercise = track.practice_exercises.find_by(uuid: 'a0acb1ec-43cb-4c65-a279-6c165eb79206')
    refute_includes exercise.prerequisites, types
    refute_includes exercise.prerequisites, dates
  end

  test "delete concept exercises no longer in config.json" do
    # TODO: Exercises shouldn't be deletable. Change this test
    # to ensure that they're not.
    skip

    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    exercise = create(:concept_exercise, track:)

    Git::SyncTrack.(track)

    refute track.concept_exercises.where(id: exercise.id).exists?
  end

  test "delete practice exercises no longer in config.json" do
    # TODO: Exercises shouldn't be deletable. Change this test
    # to ensure that they're not.
    skip
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    exercise = create(:practice_exercise, track:)

    Git::SyncTrack.(track)

    refute track.practice_exercises.where(id: exercise.id).exists?
  end

  test "delete concepts no longer in config.json" do
    # TODO: invert this test (verify that concepts can't be deleted) before release
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    concept = create(:concept, track:)

    Git::SyncTrack.(track)

    refute track.concepts.where(id: concept.id).exists?
  end

  test "update is only called once" do
    track = create :track

    # Run this once to get the track cloned onto the local machine
    Git::SyncTrack.(track)

    # Use the first commit in the repo
    track.update(synced_to_git_sha: 'e9086c7c5c9f005bbab401062fa3b2f501ecac24')

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Repository.any_instance.stubs(keep_up_to_date?: false)
    end

    Git::Repository.any_instance.expects(:fetch!).once
    Git::SyncTrack.(track)
  end

  test "syncs docs" do
    track = create :track

    Git::SyncTrackDocs.expects(:call).with(track, force_sync: false)

    # Run this once to get the track cloned onto the local machine
    Git::SyncTrack.(track)
  end

  test "open issue for sync failure when not synced successfully" do
    track = create :track
    error = StandardError.new "Could not find Concept X"
    track.stubs(:update!).raises(error)

    Github::Issue::OpenForTrackSyncFailure.expects(:call).with(track, error, track.git_head_sha)

    Git::SyncTrack.(track)
  end

  test "does not sync research experiment track" do
    track = create :track, slug: 'research_experiment_1', synced_to_git_sha: "old-sha"

    Git::SyncTrack.(track)

    assert_equal "old-sha", track.synced_to_git_sha
  end

  test "does not sync legacy javascript track" do
    track = create :track, slug: 'javascript-legacy', synced_to_git_sha: "old-sha"

    Git::SyncTrack.(track)

    assert_equal "old-sha", track.synced_to_git_sha
  end

  test "syncs has_test_runner" do
    track = create :track, has_test_runner: false

    Git::SyncTrack.(track)

    assert track.reload.has_test_runner?
  end

  test "syncs has_analyzer" do
    track = create :track, has_analyzer: true

    Git::SyncTrack.(track)

    refute track.reload.has_analyzer?
  end

  test "syncs has_representer" do
    track = create :track, has_representer: false

    Git::SyncTrack.(track)

    assert track.reload.has_representer?
  end

  test "syncs course" do
    track = create :track, course: false

    Git::SyncTrack.(track)

    assert track.course?
  end

  test "syncs highlightjs_language" do
    track = create :track, highlightjs_language: nil

    Git::SyncTrack.(track)

    assert_equal 'ruby', track.highlightjs_language
  end

  test "new concept syncs with force_sync even when track is not force synced" do
    track = create :track, synced_to_git_sha: "HEAD"

    Git::SyncConcept.expects(:call).with(anything, force_sync: true).at_least_once

    Git::SyncTrack.(track)
  end

  test "new concept exercise syncs with force_sync even when track is not force synced" do
    track = create :track, synced_to_git_sha: "HEAD"

    Git::SyncConceptExercise.expects(:call).with(anything, force_sync: true).at_least_once

    Git::SyncTrack.(track)
  end

  test "new practice exercise syncs with force_sync even when track is not force synced" do
    track = create :track, synced_to_git_sha: "HEAD"

    Git::SyncPracticeExercise.expects(:call).with(anything, force_sync: true).at_least_once

    Git::SyncTrack.(track)
  end

  test "existing concept does not sync with force_sync" do
    track = create :track, synced_to_git_sha: "HEAD"
    Git::SyncTrack.(track)

    Git::SyncConcept.expects(:call).with(anything, force_sync: true).never
    Git::SyncConcept.expects(:call).with(anything, force_sync: false).at_least_once

    Git::SyncTrack.(track)
  end

  test "existing concept exercise does not sync with force_sync" do
    track = create :track, synced_to_git_sha: "HEAD"
    Git::SyncTrack.(track)

    Git::SyncConceptExercise.expects(:call).with(anything, force_sync: true).never
    Git::SyncConceptExercise.expects(:call).with(anything, force_sync: false).at_least_once

    Git::SyncTrack.(track)
  end

  test "existing practice exercise does not sync with force_sync" do
    track = create :track, synced_to_git_sha: "HEAD"
    Git::SyncTrack.(track)

    Git::SyncPracticeExercise.expects(:call).with(anything, force_sync: true).never
    Git::SyncPracticeExercise.expects(:call).with(anything, force_sync: false).at_least_once

    Git::SyncTrack.(track)
  end

  test "reseed variable trophies" do
    track = create :track

    Track::Trophy::ReseedVariable.expects(:call).once

    Git::SyncTrack.(track)
  end
end
