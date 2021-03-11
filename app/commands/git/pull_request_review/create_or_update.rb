module Git
  class PullRequestReview
    class CreateOrUpdate
      include Mandate

      initialize_with :pull_request, :node_id, :attributes

      def call
        review = ::Git::PullRequestReview.create_or_find_by!(node_id: node_id) do |r|
          r.pull_request = pull_request
          r.reviewer_github_username = attributes[:reviewer_github_username]
        end

        review.update!(
          reviewer_github_username: attributes[:reviewer_github_username]
        )

        review
      end
    end
  end
end
