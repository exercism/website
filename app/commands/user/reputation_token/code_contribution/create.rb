class User
  class ReputationToken
    module CodeContribution
      class Create
        include Mandate

        initialize_with :user, :external_link, :size

        def call
          User::ReputationToken.find_or_create_by!(
            user: user,
            external_link: external_link,
            reason: reason,
            category: :building
          )
        end

        private
        def reason
          case size
          when :minor
            'contributed_code/minor'
          when :major
            'contributed_code/major'
          else
            'contributed_code'
          end
        end
      end
    end
  end
end
