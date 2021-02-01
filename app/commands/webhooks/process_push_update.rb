module Webhooks
  class ProcessPushUpdate
    include Mandate

    initialize_with :ref, :track_slug

    def call
      return unless pushed_to_main?
      return unless track

      ProcessPushUpdateJob.perform_later(track)
    end

    private
    memoize
    def track
      Track.find_by(slug: track_slug)
    end

    def pushed_to_main?
      ref == "refs/heads/#{Git::Repository::MAIN_BRANCH_REF}"
    end
  end
end
