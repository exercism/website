class User
  class BecomeMentor
    include Mandate

    initialize_with :user, :track_slugs

    def call
      return if user.mentor?

      raise MissingTracksError if tracks.blank?

      ActiveRecord::Base.transaction do
        user.update!(
          became_mentor_at: Time.current,
          mentored_tracks: tracks
        )
      end

      invite_to_slack!
    end

    memoize
    def tracks
      Track.where(slug: track_slugs).tap do |tracks|
        raise InvalidTrackSlugsError, track_slugs.map(&:to_s) - tracks.map(&:slug) unless tracks.size == track_slugs.size
      end
    end

    def invite_to_slack!
      data = {
        email: user.email,
        token: Exercism.secrets.slack_api_token,
        set_active: 'true'
      }
      RestClient.post(slack_api_invite_url, data)
    rescue SocketError => e
      raise e if Rails.env.production?
    end

    # TODO: Move this to config
    def slack_api_invite_url
      Rails.env.production? ? "https://exercism-mentors.slack.com/api/users.admin.invite" :
                              "https://dev.null.exercism.io"
    end
  end
end
