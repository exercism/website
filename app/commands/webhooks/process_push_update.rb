module Webhooks
  class ProcessPushUpdate
    include Mandate

    initialize_with :ref, :repo_name

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
      end
    end

    private
    def pushed_to_main?
      ref == "refs/heads/#{Git::Repository::MAIN_BRANCH_REF}"
    end
  end
end
