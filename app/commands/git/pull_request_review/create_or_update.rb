module Git
  module PullRequest
    class CreateOrUpdate
      include Mandate

      initialize_with :pull_request, :node_id, :reviewer_github_username

      def call
        ::Git::PullRequestReview.create_or_find_by!(node_id: node_id) do |r|
          r.pull_request = pull_request
          r.reviewer_github_username = reviewer_github_username
        end
      end
    end
  end
end
