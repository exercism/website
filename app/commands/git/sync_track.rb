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

    def initialize(track)
      super(track, track.synced_to_git_sha)
      @track = track
    end

    def call
      fetch_git_repo!

      return track.update!(synced_to_git_sha: head_git_track.commit.oid) unless track_needs_updating?

      # TODO: consider raising error when slug in config is different from track slug
      # TODO: validate track to prevent invalid track data
      track.update!(
        blurb: head_git_track.config[:blurb],
        active: head_git_track.config[:active],
        title: head_git_track.config[:language],
        concepts: concepts,
        concept_exercises: concept_exercises
        # TODO: re-enable once we import practice exercises
        # practice_exercises: practice_exercises
      )

      track.concepts.each { |concept| Git::SyncConcept.(concept) }
      track.concept_exercises.each { |concept_exercise| Git::SyncConceptExercise.(concept_exercise) }

      # TODO: re-enable once we import practice exercises
      # track.practice_exercises.each { |practice_exercise| Git::SyncPracticeExercise.(practice_exercise) }

      # Now that the concepts and exercises have synced successfully,
      # we can set the track's synced git SHA to the HEAD SHA
      track.update!(synced_to_git_sha: head_git_track.commit.oid)
    end

    private
    attr_reader :track

    def concepts
      # TODO: verify that all exercise concepts and prerequisites are in the concepts section
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
          # TODO: the DB used title, config.json used name. Consider if we want this
          # TODO: remove title option once tracks have all updated the config.json
          title: exercise_config[:name] || exercise_config[:slug].titleize,
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
          title: exercise_config[:slug].titleize, # TODO: what to do with practice exercise names?
          prerequisites: find_concepts(exercise_config[:prerequisites]),
          deprecated: exercise_config[:deprecated] || false,
          git_sha: head_git_track.commit.oid
        )
      end
    end

    def track_needs_updating?
      return false if synced_to_head?

      track_config_modified?
    end

    def find_concepts(concept_slugs)
      # TODO: When we have the configlet check in place
      # this should chnage to:
      # Track::Concept.where(slug: concept_slugs)
      #
      # Until then it's good to check each one and
      # return an error if one is found.
      concept_slugs.map do |concept_slug|
        track.concepts.find_by!(slug: concept_slug)
      rescue StandardError
        Rails.logger.error "Missing concept: #{concept_slug}"
        nil
      end.compact
    end

    def fetch_git_repo!
      git_repo.fetch!
    end
  end
end
