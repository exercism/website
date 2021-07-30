module Webhooks
  class ProcessPushUpdate
    include Mandate

    initialize_with :ref, :repo_owner, :repo_name, :pusher_username, :commits

    def call
      return unless pushed_to_main?

      case repo_name
      when "website-copy"
        UpdateWebsiteCopyJob.perform_later
      when "docs"
        SyncDocsJob.perform_later
      when "blog"
        SyncBlogJob.perform_later
      else
        track = Track.find_by(slug: repo_name)
        SyncTrackJob.perform_later(track) if track
        Github::DispatchEventToOrgWideFilesRepo.(:appends_update, [repo], pusher_username) if appends_file_changed?
      end
    end

    private
    def pushed_to_main?
      ref == "refs/heads/#{Git::Repository::MAIN_BRANCH_REF}"
    end

    def repo
      "#{repo_owner}/#{repo_name}"
    end

    def appends_file_changed?
      commits.to_a.any? do |commit|
        Set.new([*commit[:added], *commit[:removed], *commit[:modified]]).any? do |file|
          file.starts_with?('.appends/')
        end
      end
    end
  end
end
