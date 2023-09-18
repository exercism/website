class Partner
  class LogPerkClick
    include Mandate

    initialize_with :perk, :user, :clicked_at

    def call
      return unless valid_click?

      mongodb_collection.insert_one(doc)
      Perk.where(id: perk.id).update_all('num_clicks = num_clicks + 1')
    end

    private
    def valid_click?
      return false if user&.admin?

      true
    end

    def doc
      {
        perk_id: perk.id,
        clicked_at:
      }
    end

    def mongodb_collection
      mongodb_client[:perk_clicks]
    end

    memoize
    def mongodb_client
      Exercism.mongodb_client
    end
  end
end
