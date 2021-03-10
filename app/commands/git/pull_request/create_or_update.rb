module Git
  class PullRequest
    class CreateOrUpdate
      include Mandate

      initialize_with :node_id, :attributes

      def call
        pr = ::Git::PullRequest.create_or_find_by!(node_id: node_id) do |p|
          p.number = attributes[:pr_number]
          p.repo = attributes[:repo]
          p.author_github_username = attributes[:author]
          p.data = attributes
        end

        pr.update!(
          number: attributes[:pr_number],
          repo: attributes[:repo],
          author_github_username: attributes[:author],
          data: attributes,
          reviews: reviews(pr)
        )

        pr
      end

      private
      def reviews(pull_request)
        attributes[:reviews].to_a.map do |review|
          Git::PullRequestReview::CreateOrUpdate.(
            pull_request,
            review[:node_id],
            reviewer_github_username: review[:user][:login]
          )
        end
      end
    end
  end
end
