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
module Git
  class SyncTrack < Sync
    include Mandate

    def initialize(track, force_sync: false)
      super(track, track.synced_to_git_sha)
      @force_sync = force_sync
      @track = track
    end

    def call
      fetch_git_repo!

      # TODO: validate track using configlet to prevent invalid track data

      # TODO: consider raising error when slug in config is different from track slug

      # TODO: We should raise a bugsnag here too
      blurb = head_git_track.config[:blurb][0, 350]

      # Concepts must be synced before tracks
      sync_concepts!
      sync_concept_exercises!
      sync_practice_exercises!

      track.update!(
        blurb: blurb,
        active: head_git_track.config[:active],
        title: head_git_track.config[:language],
        tags: head_git_track.config[:tags].to_a
      )

      track.concepts.each { |concept| Git::SyncConcept.(concept) }

      Git::SyncTrackDocs.(track)

      # Now that the concepts and exercises have synced successfully,
      # we can set the track's synced git SHA to the HEAD SHA
      track.update!(synced_to_git_sha: head_git_track.commit.oid)
    end

    private
    attr_reader :track, :force_sync

    memoize
    def sync_concepts!
      head_git_track.concepts.map do |concept_config|
        ::Track::Concept::Create.(
          concept_config[:uuid],
          track,
          slug: concept_config[:slug],
          name: concept_config[:name],
          blurb: concept_blurb(concept_config[:slug]),
          synced_to_git_sha: head_git_track.commit.oid
        )
      end
    end

    memoize
    def sync_concept_exercises!
      head_git_track.concept_exercises.each_with_index do |exercise_config, position|
        exercise = ::ConceptExercise::Create.(
          exercise_config[:uuid],
          track,
          slug: exercise_config[:slug],
          git_sha: head_git_track.commit.oid,
          synced_to_git_sha: head_git_track.commit.oid,
          status: exercise_config[:status] || :active,
          position: position + 1,

          # TODO: Remove the || ... once we have configlet checking things properly.
          title: exercise_config[:name].presence || exercise_config[:slug].titleize,
          blurb: exercise_blurb(exercise_config[:slug], 'concept'),
          taught_concepts: exercise_concepts(exercise_config[:concepts]),
          prerequisites: exercise_concepts(exercise_config[:prerequisites])
        )
        Git::SyncConceptExercise.(exercise, force_sync: force_sync)
      end
    end

    memoize
    def sync_practice_exercises!
      head_git_track.practice_exercises.each_with_index do |exercise_config, position|
        exercise = ::PracticeExercise::Create.(
          exercise_config[:uuid],
          track,
          slug: exercise_config[:slug],
          git_sha: head_git_track.commit.oid,
          synced_to_git_sha: head_git_track.commit.oid,
          status: exercise_config[:status] || :active,
          position: exercise_config[:slug] == 'hello-world' ? 0 : position + 1 + head_git_track.concept_exercises.length,

          # TODO: Remove the || ... once we have configlet checking things properly.
          title: exercise_config[:name].presence || exercise_config[:slug].titleize,
          blurb: exercise_blurb(exercise_config[:slug], 'practice'),
          difficulty: exercise_config[:difficulty],
          prerequisites: exercise_concepts(exercise_config[:prerequisites]),
          practiced_concepts: exercise_concepts(exercise_config[:practices])
        )
        Git::SyncPracticeExercise.(exercise, force_sync: force_sync)
      end
    end

    def track_needs_updating?
      return true if force_sync
      return false if synced_to_head?

      true
    end

    def exercise_concepts(concept_slugs)
      track.concepts.where(slug: concept_slugs.to_a).tap do |concepts|
        # TODO: We should be able to remove this once configlet is in place
        missing_concepts = concept_slugs.to_a - concepts.map(&:slug)
        Rails.logger.error "Missing concepts: #{missing_concepts.join(', ')}" if missing_concepts.present?
      end
    end

    def exercise_blurb(slug, git_type)
      git_exercise = Git::Exercise.new(slug, git_type, git_repo.head_sha, repo: git_repo)
      git_exercise.blurb
    end

    def concept_blurb(slug)
      git_concept = Git::Concept.new(slug, git_repo.head_sha, repo: git_repo)
      git_concept.blurb
    end

    def fetch_git_repo!
      git_repo.fetch!
    end
  end
end
