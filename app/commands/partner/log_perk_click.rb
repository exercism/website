class Partner
  class LogPerkClick
    include Mandate

    initialize_with :perk, :user, :clicked_at

    def call
      Perk.where(id: perk.id).update_all('num_clicks = num_clicks + 1')
    end

    private
    def doc
      {
        perk_id: perk.id,
        clicked_at:
      }
    end
  end
end
