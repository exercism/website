class User::ReputationPeriod
  class MarkOutdated
    include Mandate

    def initialize(period:, earned_on:)
      @period = period
      @earned_on = earned_on
    end

    def call
      rows = User::ReputationToken.where(earned_on: earned_on).find_each.flat_map do |token|
        args = { user_id: token.user_id, period: period }

        # Mark rows for :any and the category as long as the category isn't publishing
        categories = [:any]
        categories << token.category unless token.category.to_sym == :publishing

        categories.flat_map do |category|
          [
            { category: category, about: :everything, track_id: 0, **args },
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
