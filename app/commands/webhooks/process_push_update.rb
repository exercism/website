module Webhooks
  class ProcessPushUpdate
    include Mandate

    initialize_with :ref, :repo_owner, :repo_name, :pusher_username, :commits, :created

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
        Github::DispatchEventToOrgWideFilesRepo.(:repo_update, [repo], pusher_username) if trigger_repo_update?
      end
    end

    private
    def pushed_to_main?
      ref == "refs/heads/#{Git::Repository::MAIN_BRANCH_REF}"
    end

    def repo
      "#{repo_owner}/#{repo_name}"
    end

    def trigger_repo_update?
      # If created is true, this is the initial commit for which we always
      # want to trigger a repo update
      return true if created

      commits.to_a.any? do |commit|
        Set.new([*commit[:added], *commit[:removed], *commit[:modified]]).any? do |file|
          file == ORG_WIDE_FILES_CONFIG_FILE || file.starts_with?('.appends/')
        end
      end
    end

    ORG_WIDE_FILES_CONFIG_FILE = '.github/org-wide-files-config.toml'.freeze
    private_constant :ORG_WIDE_FILES_CONFIG_FILE
  end
end
