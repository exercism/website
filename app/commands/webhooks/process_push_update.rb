module Webhooks
  class ProcessPushUpdate
    include Mandate

    initialize_with :ref, :track_slug

    def call
      return unless pushed_to_master?

      ProcessPushUpdateJob.perform_later(track)
    end

    private
    def track
      Track.find_by(slug: track_slug)
    end

    def pushed_to_master?
      ref == MASTER_REF
    end

    MASTER_REF = "refs/heads/master".freeze
    private_constant :MASTER_REF
  end
end
