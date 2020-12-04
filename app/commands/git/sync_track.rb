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
        synced_to_git_sha: head_git_track.commit.oid,
        concepts: concepts,
        concept_exercises: concept_exercises
        # TODO: re-enable once we import practice exercises
        # practice_exercises: practice_exercises
      )

      track.concepts.each { |concept| Git::SyncConcept.(concept) }
      track.concept_exercises.each { |concept_exercise| Git::SyncConceptExercise.(concept_exercise) }

      # TODO: re-enable once we import practice exercises
      # track.practice_exercises.each { |practice_exercise| Git::SyncPracticeExercise.(practice_exercise) }
    end

    private
    attr_reader :track

    def concepts
      # TODO: verify that all exercise concepts and prerequisites are in the concepts section
      config_concepts.map do |config_concept|
        ::Track::Concept::Create.(
          config_concept[:uuid],
          track,
          slug: config_concept[:slug],
          name: config_concept[:name],
          blurb: config_concept[:blurb],
          synced_to_git_sha: head_git_track.commit.oid
        )
      end
    end

    def concept_exercises
      config_concept_exercises.map do |exercise|
        next if exercise[:uuid].blank? # TODO: decide if we want to allow null as the uuid

        ::ConceptExercise::Create.(
          exercise[:uuid],
          track,
          slug: exercise[:slug],
          # TODO: the DB used title, config.json used name. Consider if we want this
          # TODO: remove title option once tracks have all updated the config.json
          title: exercise[:name] || exercise[:slug].titleize,
          taught_concepts: find_concepts(exercise[:concepts]),
          prerequisites: find_concepts(exercise[:prerequisites]),
          deprecated: exercise[:deprecated] || false,
          git_sha: head_git_track.commit.oid,
          synced_to_git_sha: head_git_track.commit.oid
        )
      end
    end

    def practice_exercises
      config_practice_exercises.map do |exercise|
        next if exercise[:uuid].blank? # TODO: decide if we want to allow null as the uuid

        ::PracticeExercise::Create.(
          exercise[:uuid],
          track,
          slug: exercise[:slug],
          title: exercise[:slug].titleize, # TODO: what to do with practice exercise names?
          prerequisites: find_concepts(exercise[:prerequisites]),
          deprecated: exercise[:deprecated] || false,
          git_sha: head_git_track.commit.oid,
          synced_to_git_sha: head_git_track.commit.oid
        )
      end
    end

    def track_needs_updating?
      return false if synced_to_head?

      track_config_modified?
    end

    def find_concepts(concept_slugs)
      concept_slugs.map { |concept_slug| ::Track::Concept.find_by!(slug: concept_slug) }
    end

    def fetch_git_repo!
      git_repo.fetch!
    end
  end
end
