class User::ReputationPeriod::MarkOutdated
  include Mandate

  initialize_with period: Mandate::NO_DEFAULT, earned_on: Mandate::NO_DEFAULT

  def call
    rows = User::ReputationToken.where(earned_on:).find_each.flat_map do |token|
      args = { user_id: token.user_id, period: }

      # Mark rows for :any and the category as long as the category isn't publishing
      categories = [:any]
      categories << token.category unless token.category.to_sym == :publishing

      categories.flat_map do |category|
        [
          { category:, about: :everything, track_id: 0, **args },
          (token.track_id ? { category:, about: :track, track_id: token.track_id, **args } : nil)
        ].compact
      end
    end

    rows.uniq.each { |row| User::ReputationPeriod.where(row).update_all(dirty: true) }
  end
end
