module Git
  class SyncAuthorsAndContributors
    include Mandate

    def call
      sync_exercise_authors_and_contributors!
      sync_concept_authors_and_contributors!
    end

    private
    def sync_exercise_authors_and_contributors!
      ::Exercise.find_each do |exercise|
        begin
          SyncExerciseAuthors.(exercise)
        rescue StandardError => e
          Rails.logger.error "Error syncing exercise authors for #{exercise.track.slug}/#{exercise.slug}: #{e}"
        end

        begin
          SyncExerciseContributors.(exercise)
        rescue StandardError => e
          Rails.logger.error "Error syncing exercise contributors for #{exercise.track.slug}/#{exercise.slug}: #{e}"
        end
      end
    end

    def sync_concept_authors_and_contributors!
      ::Concept.find_each do |concept|
        begin
          SyncConceptAuthors.(concept)
        rescue StandardError => e
          Rails.logger.error "Error syncing concept authors for #{concept.track.slug}/#{concept.slug}: #{e}"
        end

        begin
          SyncConceptContributors.(concept)
        rescue StandardError => e
          Rails.logger.error "Error syncing concept contributors for #{concept.track.slug}/#{concept.slug}: #{e}"
        end
      end
    end
  end
end
