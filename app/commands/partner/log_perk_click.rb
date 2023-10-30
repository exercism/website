class Partner
  class LogPerkClick
    include Mandate

    initialize_with :perk, :user, :clicked_at

    def call
      return unless valid_click?

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
  end
end
