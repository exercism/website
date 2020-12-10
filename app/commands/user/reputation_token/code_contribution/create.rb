class User
  class ReputationToken
    module CodeContribution
      class Create
        include Mandate

        initialize_with :user

        def call
          User::ReputationToken.find_or_create_by!(
            user: user,
            reason: :committed_code,
            category: :building
          )
        end
      end
    end
  end
end
