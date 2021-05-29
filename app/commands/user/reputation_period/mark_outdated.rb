class User::ReputationPeriod
  class MarkOutdated
    include Mandate

    def initialize(period:, earned_on: Time.zone.today)
      @earned_on = earned_on
      @period = period
    end

    def call
      args = { user_id: token.user_id, period: period }

      rows = User::ReputationToken.where(earned_on: earned_on).find_each.flat_map do |token|
        [:any, token.category].flat_map do |category|
          [
            { category: category, about: :everything, track_id: nil, **args },
            (token.track_id ? { category: category, about: :track, track_id: token.track_id, **args } : nil)
          ].compact
        end
      end

      rows.uniq.each { |row| User::ReputationPeriod.where(row).update_all(dirty: true) }
    end

    private
    attr_reader :earned_on, :period
  end
end
