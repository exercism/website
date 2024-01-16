# Syncing a track involves the following steps:
#
# 1. Fetch the latest data of the Git repo
# 2. Stop syncing if the track is already synced to the Git repo's HEAD commit
# 3. Update the track's metadata (title, blurb, etc.) if the track data in the
#    config.json file has changed after last syncing the track.
# 4. Update the track's concepts if the concept data in the config.json file or
#    one of the concept files (about.md, links.json, etc.) has changed after
#    last syncing the track.
# 5. Update the track's exercises if the exercise data in the config.json file
#    or one of the exercise files (instructions.md, test suite, etc.) has
#    changed after last syncing the track.
class Git::SyncTrack < Git::Sync
  include Mandate

  queue_as :default

  def initialize(track, force_sync: false)
    super(track, track.synced_to_git_sha)
    @force_sync = force_sync
    @track = track
  end

  def call
    return if skip?

    fetch_git_repo!

    # TODO: (Optional) validate track using configlet to prevent invalid track data

    # TODO: (Optional) consider raising error when slug in config is different from track slug

    # TODO: (Optional) We should raise a bugsnag here too. Note: this is not needed if
    # we validate a track using configlet
    blurb = head_git_track.blurb[0, 350]

    # Concepts must be synced before tracks
    concepts = sync_concepts!
    sync_concept_exercises!
    sync_practice_exercises!

    track.update!(
      blurb:,
      active: head_git_track.active?,
      title: head_git_track.title,
      tags: head_git_track.tags,
      course: head_git_track.has_concept_exercises?,
      has_test_runner: head_git_track.has_test_runner?,
      has_analyzer: head_git_track.has_analyzer?,
      has_representer: head_git_track.has_representer?,
      concepts:,
      highlightjs_language: head_git_track.highlightjs_language
    )

    Git::SyncTrackDocs.(track, force_sync:)
    Track::Trophy::ReseedVariable.()

    # Now that the concepts and exercises have synced successfully,
    # we can set the track's synced git SHA to the HEAD SHA
    track.update!(synced_to_git_sha: head_git_track.commit.oid)
  rescue StandardError => e
    begin
      oid = head_git_track.commit.oid
    rescue StandardError
      # oid can be nil - this is handled downstream
    end

    Github::Issue::OpenForTrackSyncFailure.(track, e, oid)
  end

  private
  attr_reader :track, :force_sync

  memoize
  def sync_concepts!
    head_git_track.concepts.map do |concept_config|
      git_concept = Git::Concept.new(concept_config[:slug], git_repo.head_sha, repo: git_repo)
      ::Concept::Create.(
        concept_config[:uuid],
        track,
        slug: concept_config[:slug],
        name: concept_config[:name],
        blurb: git_concept.blurb,
        synced_to_git_sha: head_git_track.commit.oid
      ).tap do |concept|
        Git::SyncConcept.(concept, force_sync: force_sync || concept.id_previously_changed?)
      end
    end
  end

  memoize
  def sync_concept_exercises!
    head_git_track.concept_exercises.each_with_index do |exercise_config, position|
      git_exercise = Git::Exercise.new(exercise_config[:slug], 'concept', git_repo.head_sha, repo: git_repo)
      exercise = ::Exercise::CreateConceptExercise.(
        exercise_config[:uuid],
        track,
        slug: exercise_config[:slug],
        git_sha: head_git_track.commit.oid,
        synced_to_git_sha: head_git_track.commit.oid,
        status: exercise_config[:status] || :active,
        icon_name: git_exercise.icon_name,
        position: position + 1,
        title: exercise_config[:name].presence,
        blurb: git_exercise.blurb,
        taught_concepts: exercise_concepts(exercise_config[:concepts]),
        prerequisites: exercise_concepts(head_git_track.taught_concept_slugs & exercise_config[:prerequisites].to_a),
        has_test_runner: git_exercise.has_test_runner?,
        representer_version: git_exercise.representer_version
      )
      Git::SyncConceptExercise.(exercise, force_sync: force_sync || exercise.id_previously_changed?)
    end
  end

  memoize
  def sync_practice_exercises!
    head_git_track.practice_exercises.each_with_index do |exercise_config, position|
      git_exercise = Git::Exercise.new(exercise_config[:slug], 'practice', git_repo.head_sha, repo: git_repo)
      exercise = ::Exercise::CreatePracticeExercise.(
        exercise_config[:uuid],
        track,
        slug: exercise_config[:slug],
        git_sha: head_git_track.commit.oid,
        synced_to_git_sha: head_git_track.commit.oid,
        status: exercise_config[:status] || :active,
        icon_name: git_exercise.icon_name,
        position: exercise_config[:slug] == 'hello-world' ? 0 : position + 1 + head_git_track.concept_exercises.length,
        title: exercise_config[:name].presence,
        blurb: git_exercise.blurb,
        difficulty: exercise_config[:difficulty],
        prerequisites: exercise_concepts(head_git_track.taught_concept_slugs & exercise_config[:prerequisites].to_a),
        practiced_concepts: exercise_concepts(exercise_config[:practices]),
        has_test_runner: git_exercise.has_test_runner?,
        representer_version: git_exercise.representer_version
      )
      Git::SyncPracticeExercise.(exercise, force_sync: force_sync || exercise.id_previously_changed?)
    end
  end

  def exercise_concepts(concept_slugs)
    track.concepts.where(slug: concept_slugs.to_a).tap do |concepts|
      # TODO: (Optional) We should be able to remove this once configlet is in place
      missing_concepts = concept_slugs.to_a - concepts.map(&:slug)
      Rails.logger.error "Missing concepts: #{missing_concepts.join(', ')}" if missing_concepts.present?
    end
  end

  def fetch_git_repo!
    git_repo.fetch!
  end

  def skip?
    %w[research_experiment_1 javascript-legacy].include?(track.slug)
  end
end
