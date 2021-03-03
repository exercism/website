module Git
  class SyncAuthorsAndContributors
    include Mandate

    def call
      ::Exercise.all.each do |exercise|
        begin
          SyncAuthors.(exercise)
        rescue StandardError => e
          Rails.logger.error "Error syncing authors for #{exercise.track.slug}/#{exercise.slug}: #{e}"
        end

        begin
          SyncContributors.(exercise)
        rescue StandardError => e
          Rails.logger.error "Error syncing contributors for #{exercise.track.slug}/#{exercise.slug}: #{e}"
        end
      end
    end
  end
end
