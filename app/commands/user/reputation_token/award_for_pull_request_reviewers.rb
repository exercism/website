class User
  class ReputationToken
    class AwardForPullRequestReviewers
      include Mandate

      initialize_with :params

      def call
        return unless has_reviews?
        return unless just_closed?

        reviewer_usernames = params[:reviews].to_a.map { |reviewer| reviewer[:reviewer] }.uniq
        reviewer_usernames.delete(params[:author]) # Don't award reviewer reputation to the PR author

        reviewers = ::User.where(github_username: reviewer_usernames)
        reviewers.find_each do |reviewer|
          User::ReputationToken::Create.(
            reviewer,
            :code_review,
            repo: params[:repo],
            pr_node_id: params[:pr_node_id],
            pr_number: params[:pr_number],
            external_link: params[:html_url]
          )
        end

        # TODO: consider what to do with missing reviewers
        missing_reviewers = reviewer_usernames - reviewers.pluck(:handle)
        Rails.logger.error "Missing reviewers: #{missing_reviewers.join(', ')}" if missing_reviewers.present?
      end

      private
      def has_reviews?
        params[:reviews].present?
      end

      def just_closed?
        params[:action] == 'closed'
      end
    end
  end
end
