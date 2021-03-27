class UserTrack
  class MonitorChanges
    include Mandate

    def self.call(*args, &block)
      new(*args, &block).()
    end

    def initialize(user_track, &block)
      @user_track = user_track
      @block = block
    end

    def call
      # Get the initial state. We need the first three to be arrays,
      # not ActiveRecord::Relations, as we need the SQL to run before
      # the block is called below.
      unlocked_exercise_ids = user_track.unlocked_exercise_ids
      unlocked_concept_ids = user_track.unlocked_concept_ids
      concept_progressions = user_track.concept_progressions

      # This triggers the action that we're monitor.
      # For example, we might complete an exercise here
      block.()

      # Now we reload the user_track, knowing that the data has changed.
      updated_user_track = UserTrack.find(user_track.id)

      # Work out which exercise and concepts are newly avaliable
      unlocked_exercise_ids = updated_user_track.unlocked_exercise_ids - unlocked_exercise_ids
      unlocked_concept_ids = updated_user_track.unlocked_concept_ids - unlocked_concept_ids

      # Build a before and after of each concept progression and keep any that have changed
      concept_progressions = updated_user_track.concept_progressions.map do |id, data|
        {
          id: id,
          total: data[:total],
          from: concept_progressions[id][:completed],
          to: data[:completed]
        }
      end
      concept_progressions.reject! { |cp| cp[:to] == cp[:from] }

      # Inject the concept into each result, and remove id
      progressed_concepts = Track::Concept.where(
        id: concept_progressions.map { |c| c[:id] }
      ).index_by(&:id)

      concept_progressions.map do |cp|
        cp[:concept] = progressed_concepts[cp[:id]]
        cp.delete(:id)
      end

      # And finally return it all as a neat hash
      {
        unlocked_exercises: Exercise.where(id: unlocked_exercise_ids),
        unlocked_concepts: Track::Concept.where(id: unlocked_concept_ids),
        concept_progressions: concept_progressions
      }
    end

    private
    attr_reader :user_track, :block
  end
end
