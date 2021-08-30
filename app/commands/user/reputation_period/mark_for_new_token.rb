class User::ReputationPeriod
  class MarkForNewToken
    include Mandate

    initialize_with :token

    def call
      args = { user_id: token.user_id, user_handle: token.user.handle, dirty: true }

      rows = %i[forever year month week].flat_map do |period|
        # Make rows for :any and the category as long as the category isn't publishing
        categories = [:any]
        categories << token.category unless token.category.to_sym == :publishing

        categories.flat_map do |category|
          [
            { period: period, category: category, about: :everything, track_id: 0, **args },
            (token.track_id ? { period: period, category: category, about: :track, track_id: token.track_id, **args } : nil)
          ].compact
        end
      end

      # TODO: (Optional) When new version of Rails is released, change to this:
      # User::ReputationPeriod.upsert_all(rows, on_duplicate: {dirty: false})
      User::ReputationPeriod.upsert_all(rows)
    end
  end
end
