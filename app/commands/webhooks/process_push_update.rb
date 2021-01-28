module Webhooks
  class ProcessPushUpdate
    include Mandate

    initialize_with :ref, :track_slug

    def call
      return unless pushed_to_main?

      ProcessPushUpdateJob.perform_later(track)
    end

    private
    def track
      Track.find_by(slug: track_slug)
    end

    def pushed_to_main?
      ref == Git::Repository::MAIN_BRANCH_REF
    end
  end
end
