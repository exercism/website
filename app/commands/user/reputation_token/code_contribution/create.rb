class User
  class ReputationToken
    module CodeContribution
      class Create
        include Mandate

        initialize_with :user, :external_link

        def call
          User::ReputationToken.find_or_create_by!(
            user: user,
            external_link: external_link,
            reason: 'committed_code',
            category: :building
          )
        end
      end
    end
  end
end
