module Webhooks
  class ProcessPushUpdate
    include Mandate

    initialize_with :ref, :repo_name

    def call
      return unless pushed_to_main?
      return unless website_copy? || track

      ProcessPushUpdateJob.perform_later(track)
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
