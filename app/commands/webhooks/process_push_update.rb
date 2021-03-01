module Webhooks
  class ProcessPushUpdate
    include Mandate

    initialize_with :ref, :repo_name

    def call
      return unless pushed_to_main?

      if website_copy?
        UpdateWebsiteCopyJob.perform_later
      elsif track
        SyncTrackJob.perform_later(track)
      end
    end

    private
    def website_copy?
      repo_name == "website-copy"
    end

    memoize
    def track
      Track.find_by(slug: repo_name)
    end

    def pushed_to_main?
      ref == "refs/heads/#{Git::Repository::MAIN_BRANCH_REF}"
    end
  end
end
