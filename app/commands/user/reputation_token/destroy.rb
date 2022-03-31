class User
  class ReputationToken
    class Destroy
      include Mandate

      initialize_with :token

      def call
        token.destroy!
        User::ReputationPeriod::MarkForToken.(token)
      end
    end
  end
end
