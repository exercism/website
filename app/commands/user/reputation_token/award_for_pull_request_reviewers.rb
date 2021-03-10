class User
  class ReputationToken
    class AwardForPullRequestReviewers
      include Mandate

      initialize_with :action, :github_username, :params

      def call
        return unless just_closed?

        reviewer_usernames = reviews.map { |reviewer| reviewer[:reviewer] }.uniq
        reviewer_usernames.delete(github_username) # Don't award reviewer reputation to the PR author

        reviewers = ::User.where(github_username: reviewer_usernames)
        reviewers.find_each do |reviewer|
          User::ReputationToken::Create.(
            reviewer,
            :code_review,
            repo: repo,
            pr_id: pr_id,
            pr_number: pr_number,
            external_link: external_link
          )
        end

        # TODO: consider what to do with missing reviewers
        missing_reviewers = reviewer_usernames - reviewers.map(&:handle)
        Rails.logger.error "Missing reviewers: #{missing_reviewers.join(', ')}" if missing_reviewers.present?
      end

      private
      def just_closed?
        action == 'closed'
      end

      def external_link
        params[:html_url]
      end

      def repo
        params[:repo]
      end

      def pr_id
        params[:pr_id]
      end

      def pr_number
        params[:pr_number]
      end

      def reviews
        params[:reviews].to_a
      end
    end
  end
end
