class Partner
  class LogAdvertImpression
    include Mandate

    queue_as :background

    initialize_with :uuid, :advert, :user, :ip_address, :shown_at, :request_path

    def call
      return unless valid_impression?

      Advert.where(id: advert.id).update_all('num_impressions = num_impressions + 1')
    end

    private
    def valid_impression?
      return false if request_path.starts_with?('/admin')
      return false if user&.admin?

      true
    end

    def doc
      {
        _id: uuid,
        advert_id: advert.id,
        user_id: user&.id,
        ip_address:,
        track_slug:,
        shown_on: request_path,
        shown_at_yearmonth: "#{shown_at.year}#{shown_at.month.to_s.rjust(2, '0')}",
        shown_at_timestamp: shown_at.to_i
      }
    end

    def track_slug
      %r{^/tracks/([^/]+)}.match(request_path)&.captures&.first
    end
  end
end
