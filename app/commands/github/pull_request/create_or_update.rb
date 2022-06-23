module Github
  class PullRequest
    class CreateOrUpdate
      include Mandate

      initialize_with :node_id, :attributes

      def call
        pull_request = ::Github::PullRequest.create_or_find_by!(node_id:) do |pr|
          pr.attributes = attributes.except(:reviews)
        end

        pull_request.tap do |pr|
          pr.update!(attributes.merge(reviews: reviews(pr)))
        end
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
