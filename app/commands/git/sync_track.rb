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
      sync_metadata!
      sync_concepts!
      sync_exercises!
    end

    def sync_metadata!
      return track.update!(synced_to_git_sha: head_git_track.commit.oid) unless track_needs_updating?

      # TODO: consider raising error when slug in config is different from track slug
      # TODO: validate track to prevent invalid track data
      track.update!(
        blurb: head_git_track.config[:blurb],
        active: head_git_track.config[:active],
        title: head_git_track.config[:language],
        synced_to_git_sha: head_git_track.commit.oid
      )
    end

    def sync_exercises!
      track.concept_exercises.each { |concept| Git::SyncExercise.(concept) }
      track.practice_exercises.each { |concept| Git::SyncExercise.(concept) }
    end

    def sync_concepts!
      concepts = config_concepts.map do |config_concept|
        ::Track::Concept.create_or_find_by!(uuid: config_concept[:uuid]) do |c|
          c.slug = config_concept[:slug]
          c.name = config_concept[:name]
          c.blurb = config_concept[:blurb]
          c.synced_to_git_sha = head_git_track.commit.oid
          c.track = track
        end
      end

      # TODO: verify that all exercise concepts and prerequisites are in the concepts section
      track.concepts.replace(concepts)
      track.concepts.each { |concept| Git::SyncConcept.(concept) }
    end

    def track_needs_updating?
      track_config_modified?
    end

    memoize
    def config_exercises
      head_git_track.config[:exercises]
    end

    memoize
    def config_concepts
      head_git_track.config[:concepts]
    end
  end
end
