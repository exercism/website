module Git
  class PullRequest
    class CreateOrUpdate
      include Mandate

      initialize_with :node_id, :attributes

      def call
        pull_request = ::Git::PullRequest.create_or_find_by!(node_id: node_id) do |pr|
          pr.number = attributes[:pr_number]
          pr.repo = attributes[:repo]
          pr.author_github_username = attributes[:author]
          pr.data = attributes[:data]
        end

        pull_request.update!(
          number: attributes[:pr_number],
          repo: attributes[:repo],
          author_github_username: attributes[:author],
          data: attributes[:data],
          reviews: reviews(pr)
        )

        pull_request
      end

      private
      def reviews(pull_request)
        attributes[:reviews].to_a.map do |review|
          Git::PullRequestReview::Create.(
            pull_request,
            review[:node_id],
            reviewer_github_username: review[:reviewer]
          )
        end
      end

      def data
        {
          action: attributes[:action],
          author: attributes[:login],
          url: attributes[:url],
          html_url: attributes[:html_url],
          labels: attributes[:labels],
          repo: attributes[:repo],
          pr_id: attributes[:pr_id],
          pr_number: attributes[:pr_number],
          merged: attributes[:merged],
          merged_by: attributes[:merged_by],
          state: attributes[:state],
          reviews: attributes[:reviews]
        }
      end
    end
  end
end
