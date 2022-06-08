module Github
  class PullRequest
    class CreateOrUpdate
      include Mandate

      initialize_with :node_id, :attributes

      def call
        pull_request = ::Github::PullRequest.create_or_find_by!(node_id:) do |pr|
          pr.number = attributes[:number]
          pr.title = attributes[:title]
          pr.repo = attributes[:repo]
          pr.author_username = attributes[:author_username]
          pr.merged_by_username = attributes[:merged_by_username]
          pr.data = attributes[:data]
        end

        pull_request.update!(
          number: attributes[:number],
          title: attributes[:title],
          repo: attributes[:repo],
          author_username: attributes[:author_username],
          merged_by_username: attributes[:merged_by_username],
          data: attributes[:data],
          reviews: reviews(pull_request)
        )

        pull_request
      end

      private
      def reviews(pull_request)
        attributes[:reviews].to_a.map do |review|
          Github::PullRequestReview::CreateOrUpdate.(pull_request, review[:node_id], review[:reviewer_username])
        end
      end
    end
  end
end
