class User
  class ReputationToken
    module CodeReview
      class Create
        include Mandate

        initialize_with :user, :external_link, :repo, :number, :reason

        def call
          User::ReputationToken.create_or_find_by!(
            user: user,
            context_key: "reviewed_code/#{repo}/pulls/#{number}"
          ) do |rt|
            rt.external_link = external_link
            rt.reason = reason
            rt.category = :building
          end
        end
      end
    end
  end
end
