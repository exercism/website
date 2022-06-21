module Github
  class PullRequest
    class CreateOrUpdate
      include Mandate

      initialize_with :node_id, :attributes

      def call
        pull_request = ::Github::PullRequest.create_or_find_by!(node_id:) do |pr|
          pr.attributes = attributes.except(:reviews)
        end

        log_metrics!

        pull_request.tap do |pr|
          pr.update!(attributes.merge(reviews: reviews(pr)))
        end

        log_metrics!

        pull_request
      end

      private
      attr_reader :pull_request

      def reviews(pull_request)
        attributes[:reviews].to_a.map do |review|
          Github::PullRequestReview::CreateOrUpdate.(pull_request, review[:node_id], review[:reviewer_username])
        end
      end

      def log_metrics!
        log_open_metrics! if pull_request.just_created?
        log_merge_metrics! if pull_request.merged_by_username_previously_changed?(from: nil)
      end

      def log_open_metrics!
        Metric::Queue.(:open_pull_request, created_at, track:, user: author)
      end

      def log_merge_metrics!
        Metric::Queue.(:merge_pull_request, merged_at, track:, user: merged_by)
      end

      def track = Track.for_repo(pull_request.repo)

      def created_at = pull_request.data[:created_at] || pull_request.created_at
      def author = User.find_by(github_username: pull_request.data[:author_username])

      def merged_at = pull_request.data[:merged_at] || pull_request.updated_at
      def merged_by = User.find_by(github_username: pull_request.data[:merged_by_username])
    end
  end
end
