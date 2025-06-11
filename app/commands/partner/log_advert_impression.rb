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
  end
end
