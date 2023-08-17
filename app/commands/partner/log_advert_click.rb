class Partner
  class LogAdvertClick
    include Mandate

    initialize_with :advert, :user, :clicked_at, :impression_uuid

    def call
      return unless valid_click?

      mongodb_collection.insert_one(doc)
      Advert.where(id: advert.id).update_all('num_clicks = num_clicks + 1')
    ensure
      mongodb_client.close
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

    def mongodb_collection
      mongodb_client[:advert_clicks]
    end

    memoize
    def mongodb_client
      Exercism.mongodb_client
    end
  end
end
