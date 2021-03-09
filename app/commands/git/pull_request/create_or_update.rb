module Git
  module PullRequest
    class CreateOrUpdate
      include Mandate

      initialize_with :pr

      def call
        ::Git::PullRequest.new(
          node_id: pr[:pr_id],
          number: pr[:pr_number],
          author_github_username: pr[:author],
          repo: pr[:repo],
          data: pr,
          reviews: pr[:reviews].map do |review|
            ::Git::PullRequestReview.new(
              node_id: review[:node_id],
              reviewer_github_username: review[:user][:login]
            )
          end
        ).save!

        # TODO: update pr
        # rescue ActiveRecord::RecordNotUnique
        #   nil
        # end
      end
    end
  end
end
