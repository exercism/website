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
      track.update!(
        blurb: head_git_track.config[:blurb],
        active: head_git_track.config[:active],
        title: head_git_track.config[:language],
        tags: head_git_track.config[:tags].to_a,
        concepts: concepts,
        concept_exercises: concept_exercises,
        practice_exercises: practice_exercises
      )

      track.concepts.each { |concept| Git::SyncConcept.(concept) }
      track.concept_exercises.each { |concept_exercise| Git::SyncConceptExercise.(concept_exercise) }
      track.practice_exercises.each { |practice_exercise| Git::SyncPracticeExercise.(practice_exercise) }

      # Now that the concepts and exercises have synced successfully,
      # we can set the track's synced git SHA to the HEAD SHA
      track.update!(synced_to_git_sha: head_git_track.commit.oid)
    end

    private
    attr_reader :track, :force_sync

    def concepts
      concepts_config.map do |concept_config|
        ::Track::Concept::Create.(
          concept_config[:uuid],
          track,
          slug: concept_config[:slug],
          name: concept_config[:name],
          blurb: concept_config[:blurb],
          synced_to_git_sha: head_git_track.commit.oid
        )
      end
    end

    def concept_exercises
      concept_exercises_config.map do |exercise_config|
        next if exercise_config[:uuid].blank? # TODO: decide if we want to allow null as the uuid

        ::ConceptExercise::Create.(
          exercise_config[:uuid],
          track,
          slug: exercise_config[:slug],

          # TODO: Remove the || ... once we have configlet checking things properly.
          title: exercise_config[:name].presence || exercise_config[:slug].titleize,
          taught_concepts: find_concepts(exercise_config[:concepts]),
          prerequisites: find_concepts(exercise_config[:prerequisites]),
          deprecated: exercise_config[:deprecated] || false,
          git_sha: head_git_track.commit.oid
        )
      end
    end

    def practice_exercises
      practice_exercises_config.map do |exercise_config|
        next if exercise_config[:uuid].blank? # TODO: decide if we want to allow null as the uuid

        ::PracticeExercise::Create.(
          exercise_config[:uuid],
          track,
          slug: exercise_config[:slug],
          # TODO: Remove the || ... once we have configlet checking things properly.
          title: exercise_config[:name].presence || exercise_config[:slug].titleize,
          prerequisites: find_concepts(exercise_config[:prerequisites]),
          deprecated: exercise_config[:deprecated] || false,
          git_sha: head_git_track.commit.oid
        )
      end
    end

    def track_needs_updating?
      return true if force_sync
      return false if synced_to_head?

      true
    end

    def find_concepts(concept_slugs)
      track.concepts.where(slug: concept_slugs).tap do |concepts|
        # TODO: We should be able to remove this once configlet is in place
        missing_concepts = concept_slugs - concepts.map(&:slug)
        Rails.logger.error "Missing concepts: #{missing_concepts.join(', ')}" if missing_concepts.present?
      end
    end

    def fetch_git_repo!
      git_repo.fetch!
    end
  end
end
