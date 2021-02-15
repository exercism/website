class User
  class ReputationToken
    class Create
      include Mandate

      initialize_with :user, :type, :params

      def call
        klass = "user/reputation_tokens/#{type}_token".camelize.constantize

        klass.new(
          user: user,
          params: params
        ).tap do |token|
          token.save
        rescue ActiveRecord::RecordNotUnique
          return klass.find_by!(user: user, uniqueness_key: token.uniqueness_key)

          # ...
        end
      end
    end
  end
end
