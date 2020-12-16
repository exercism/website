class User
  class ReputationToken
    module CodeContribution
      class Create
        include Mandate

        initialize_with :user, :reason, :repo, :pr_id, :external_link

        def call
          reputation_token = User::ReputationToken.create_or_find_by!(
            user: user,
            context_key: "contributed_code/#{repo}/pulls/#{pr_id}"
          ) do |rt|
            rt.external_link = external_link
            rt.reason = reason
            rt.category = :building
          end

          # Reasons are mutable and this class may be called multiple times
          # if the reason changes (via labels being changed on PRs)
          reputation_token.update!(reason: reason)
        end
      end
    end
  end
end
