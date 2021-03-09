module Git
  module PullRequest
    class CreateOrUpdate
      include Mandate

      initialize_with :node_id, :attributes

      def call
        pr = ::Git::PullRequest.create_or_find_by!(node_id: pr[:pr_id]) do |p|
          p.attributes = attributes
        end

        # This will remove any reviews that have been dismissed
        pr.update!(reviews: reviews)
        end
      end

      private
      def reviews
        reviews.map do |review|
          ::Git::PullRequestReview::CreateOrUpdate(review[:node_id],
            reviewer_github_username: review[:user][:login])
        end
      end
    end
  end
end
