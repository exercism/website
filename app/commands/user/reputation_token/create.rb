class User
  class ReputationToken
    class Create
      include Mandate

      initialize_with :user, :type, :params

      def call
        return if user.system? || user.ghost?

        klass = "user/reputation_tokens/#{type}_token".camelize.constantize

        klass.new(
          user:,
          params:
        ).tap do |token|
          token.save!

          AwardBadgeJob.perform_later(user, :contributor, context: token)
          User::ReputationPeriod::MarkForToken.(token)
        rescue ActiveRecord::RecordNotUnique
          return klass.find_by!(user:, uniqueness_key: token.uniqueness_key)
        end
      end
    end
  end
end
