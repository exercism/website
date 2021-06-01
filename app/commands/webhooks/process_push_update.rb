module Webhooks
  class ProcessPushUpdate
    include Mandate

    initialize_with :ref, :repo_name, :commits

    def call
      return unless pushed_to_main?

      case repo_name
      when "website-copy"
        UpdateWebsiteCopyJob.perform_later
      when "docs"
        SyncDocsJob.perform_later
      else
        track = Track.find_by(slug: repo_name)
        SyncTrackJob.perform_later(track) if track
        NotifyTrackSyncerAboutTrackChangesJob.perform_later(track) if org_wide_file_changed?(track)
      end
    end

    private
    def pushed_to_main?
      ref == "refs/heads/#{Git::Repository::MAIN_BRANCH_REF}"
    end

    def org_wide_file_changed?(track)
      return false unless track

      commits.to_a.any? do |commit|
        Set.new([*commit[:added], *commit[:removed], *commit[:modified]]).any? do |file|
          file.starts_with?('.appends/')
        end
      end
    end
  end
end
