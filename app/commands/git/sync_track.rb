module Git
  class SyncTrack < Sync
    include Mandate

    def initialize(track)
      super(track, track.synced_to_git_sha)
      @track = track
    end

    private
    attr_reader :track

    def sync!
      return track.update!(synced_to_git_sha: head_git_track.commit.oid) unless track_needs_updating?

      # TODO: consider raising error when slug in config is different from track slug
      # TODO: validate track to prevent invalid track data
      track.update!(
        blurb: head_git_track.config[:blurb],
        active: head_git_track.config[:active],
        title: head_git_track.config[:language],
        synced_to_git_sha: head_git_track.commit.oid,
        concepts: concepts,
        concept_exercises: concept_exercises,
        practice_exercises: practice_exercises
      )

      # TODO: enable syncing
      # track.concepts.each { |concept| Git::SyncConcept.(concept) }
      # track.concept_exercises.each { |concept| Git::SyncExercise.(concept) }
      # track.practice_exercises.each { |concept| Git::SyncExercise.(concept) }
    end

    def concepts
      # TODO: verify that all exercise concepts and prerequisites are in the concepts section
      config_concepts.map do |config_concept|
        ::Track::Concept::Create.(
          config_concept[:uuid],
          config_concept[:slug],
          config_concept[:name],
          config_concept[:blurb],
          head_git_track.commit.oid,
          track
        )
      end
    end

    def concept_exercises
      config_concept_exercises.map do |exercise|
        ::ConceptExercise::Create.(
          exercise[:uuid],
          exercise[:slug],
          exercise[:name], # TODO: the DB used title, config.json used name. Consider if we want this
          find_concepts(exercise[:concepts]),
          find_concepts(exercise[:prerequisites]),
          exercise[:deprecated] || false,
          track.synced_to_git_sha,
          track.synced_to_git_sha,
          track
        )
      end
    end

    def practice_exercises
      config_concept_exercises.map do |exercise|
        ::PracticeExercise::Create.(
          exercise[:uuid],
          exercise[:slug],
          exercise[:name], # TODO: what to do with practice exercise names?
          find_concepts(exercise[:prerequisites]),
          exercise[:deprecated] || false,
          track.synced_to_git_sha,
          track.synced_to_git_sha,
          track
        )
      end
    end

    def track_needs_updating?
      track_config_modified?
    end

    def find_concepts(concept_slugs)
      concept_slugs.map { |concept_slug| ::Track::Concept.find_by!(slug: concept_slug) }
    end
  end
end
