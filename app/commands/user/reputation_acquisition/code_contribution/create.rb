class User
  class ReputationAcquisition
    module CodeContribution
      class Create
        include Mandate

        initialize_with :user

        def call
          User::ReputationAcquisition.find_or_create_by!(
            user: user,
            reason: :code_contribution,
            category: "code_contribution"
          )
        end
      end
    end
  end
end
