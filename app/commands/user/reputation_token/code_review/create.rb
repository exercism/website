class User
  class ReputationToken
    module CodeReview
      class Create
        include Mandate

        initialize_with :user, :repo, :pr_id, :external_link

        def call
          User::ReputationToken.create_or_find_by!(
            user: user,
            context_key: "reviewed_code/#{repo}/pulls/#{pr_id}"
          ) do |rt|
            rt.external_link = external_link
            rt.reason = :reviewed_code
            rt.category = :building

            # TODO: Set rt.track here.
          end
        end
      end
    end
  end
end
