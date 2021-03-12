class User
  class ReputationToken
    class AwardForPullRequestReviewers
      include Mandate

      initialize_with :params

      def call
        return unless has_reviews?
        return unless just_closed?

        reviewer_usernames = params[:reviews].
          to_a.
          map { |reviewer| reviewer[:reviewer_username] }.
          compact.
          uniq
        reviewer_usernames.delete(params[:author_username]) # Don't award reviewer reputation to the PR author

        reviewers = ::User.where(github_username: reviewer_usernames)
        reviewers.find_each do |reviewer|
          User::ReputationToken::Create.(
            reviewer,
            :code_review,
            repo: params[:repo],
            pr_node_id: params[:node_id],
            pr_number: params[:number],
            pr_title: params[:title],
            external_link: params[:html_url]
          )
        end

        # TODO: consider what to do with missing reviewers
        missing_reviewers = reviewer_usernames - reviewers.pluck(:github_username)
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
