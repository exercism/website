class Partner
  class LogAdvertClick
    include Mandate

    queue_as :background

    initialize_with :advert, :user, :clicked_at, :impression_uuid

    def call
      Advert.where(id: advert.id).update_all('num_clicks = num_clicks + 1')
    end

    private
    def doc
      {
        advert_id: advert.id,
        impression_uuid:,
        clicked_at:
      }
    end
  end
end
