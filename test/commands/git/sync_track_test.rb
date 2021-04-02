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

    Git::SyncConcept.expects(:call).at_least_once
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

    assert_raises RuntimeError do
      Git::SyncTrack.(track)
    end

    assert_equal "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", track.synced_to_git_sha
  end

  test "git sync SHA does not change when concept exercise syncing fails" do
    track = create :track, active: true, synced_to_git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a"
    Git::SyncConceptExercise.expects(:call).raises(RuntimeError)

    assert_raises RuntimeError do
      Git::SyncTrack.(track)
    end

    assert_equal "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", track.synced_to_git_sha
  end

  test "git sync SHA does not change when practice exercise syncing fails" do
    track = create :track, active: true, synced_to_git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a"
    Git::SyncPracticeExercise.expects(:call).raises(RuntimeError)

    assert_raises RuntimeError do
      Git::SyncTrack.(track)
    end

    assert_equal "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", track.synced_to_git_sha
  end

  test "track is updated when there are changes" do
    track = create :track, slug: "ruby",
                           title: "Ruby",
                           active: true,
                           blurb: "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write.", # rubocop:disable Layout/LineLength
                           synced_to_git_sha: "aad630acfbbdef16d90105a205b957c138fa1b93"

    Git::SyncTrack.(track)

    assert_equal "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity.", track.blurb # rubocop:disable Layout/LineLength
  end

  test "track is updated when tags change" do
    track = create :track, slug: "fsharp",
                           title: "F#",
                           active: true,
                           blurb: "F# is a strongly-typed, functional language that is part of Microsoft's .NET language stack. Although F# is great for data science problems, it can elegantly handle almost every problem you throw at it.", # rubocop:disable Layout/LineLength
                           tags: ["execution_mode/interpreted", "platform/windows", "platform/linux", "paradigm/declarative", "paradigm/object_oriented"], # rubocop:disable Layout/LineLength
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

    assert_equal 9, track.concepts.length
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
    expected_order = %w[hello-world allergies anagram bob hamming isogram leap satellite space-age]
    assert_equal expected_order, actual_order
  end

  test "first position is for hello-world exercise, followed by concept exercises and then practice exercises" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'

    Git::SyncTrack.(track)

    actual_order = track.exercises.order(:position).pluck(:slug)
    expected_order = %w[
      hello-world
      arrays booleans lasagna log-levels numbers strings allergies
      anagram bob hamming isogram leap satellite space-age
    ]
    assert_equal expected_order, actual_order
  end

  test "concept exercises use track concepts for taught concepts" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    track_concept = create :track_concept, track: track, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    other_track = create :track, slug: 'fsharp'
    other_track_concept = create :track_concept, track: other_track, slug: 'basics'

    Git::SyncTrack.(track)

    track_concept_exercise = track.concept_exercises.find_by(uuid: '71ae39c4-7364-11ea-bc55-0242ac130003')
    assert_includes track_concept_exercise.taught_concepts, track_concept
    refute_includes track_concept_exercise.taught_concepts, other_track_concept
  end

  test "concept exercises use track concepts for prerequisites" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    track_concept = create :track_concept, track: track, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e'
    other_track = create :track, slug: 'fsharp'
    other_track_concept = create :track_concept, track: other_track, slug: 'basics'

    Git::SyncTrack.(track)

    track_concept_exercise = track.concept_exercises.find_by(uuid: 'e5476046-5289-11ea-8d77-2e728ce88125')
    assert_includes track_concept_exercise.prerequisites, track_concept
    refute_includes track_concept_exercise.prerequisites, other_track_concept
  end

  test "practice exercises use track concepts for prerequisites" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    track_concept = create :track_concept, track: track, slug: 'dates', uuid: '091f10d6-99aa-47f4-9eff-0e62eddbee7a'
    other_track = create :track, slug: 'fsharp'
    other_track_concept = create :track_concept, track: other_track, slug: 'dates'

    Git::SyncTrack.(track)

    track_practice_exercise = track.practice_exercises.find_by(uuid: 'a0acb1ec-43cb-4c65-a279-6c165eb79206')
    assert_includes track_practice_exercise.prerequisites, track_concept
    refute_includes track_practice_exercise.prerequisites, other_track_concept
  end

  test "practice exercises use track concepts for practiced concepts" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    track_concept = create :track_concept, track: track, slug: 'time', uuid: '4055d823-e100-4a46-89d3-dcb01dd6043f'
    other_track = create :track, slug: 'fsharp'
    other_track_concept = create :track_concept, track: other_track, slug: 'time'

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

    assert_equal 9, track.practice_exercises.length
  end

  test "syncs all concepts" do
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'

    Git::SyncTrack.(track)

    assert_equal 9, track.concepts.length
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

    assert_equal 9, track.practice_exercises.length
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

    assert_equal 9, track.practice_exercises.length
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

    assert_equal 9, track.practice_exercises.length
  end

  test "delete concept exercises no longer in config.json" do
    # TODO: invert this test (verify that concept exercises can't be deleted) before release
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    exercise = create :concept_exercise, track: track

    Git::SyncTrack.(track)

    refute track.concept_exercises.where(id: exercise.id).exists?
  end

  test "delete practice exercises no longer in config.json" do
    # TODO: invert this test (verify that practice exercises can't be deleted) before release
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    exercise = create :practice_exercise, track: track

    Git::SyncTrack.(track)

    refute track.practice_exercises.where(id: exercise.id).exists?
  end

  test "delete concepts no longer in config.json" do
    # TODO: invert this test (verify that concepts can't be deleted) before release
    track = create :track, synced_to_git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a'
    concept = create :track_concept, track: track

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

    Git::SyncTrackDocs.expects(:call).with(track)

    # Run this once to get the track cloned onto the local machine
    Git::SyncTrack.(track)
  end
end
