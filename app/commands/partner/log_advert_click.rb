class Partner
  class LogAdvertClick
    include Mandate

    queue_as :background

    initialize_with :advert, :user, :clicked_at, :impression_uuid

    def call
      return unless valid_click?

      Advert.where(id: advert.id).update_all('num_clicks = num_clicks + 1')
    end

    private
    def valid_click?
      return false if user&.admin?

      true
    end

    def doc
      {
        advert_id: advert.id,
        impression_uuid:,
        clicked_at:
      }
    end
  end
end
