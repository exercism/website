class User
  class ReputationToken
    class AwardForPullRequestMerger
      include Mandate

      initialize_with :action, :github_username, :params

      def call
        return unless merged?

        user = User.find_by(github_username: merged_by)

        # TODO: decide what to do with user that cannot be found
        Rails.logger.error "Missing merged by user: #{merged_by}" unless user
        return unless user

        User::ReputationToken::Create.(
          user,
          :code_merge,
          repo: repo,
          pr_id: pr_id,
          pr_number: pr_number,
          external_link: external_link
        )
      end

      private
      def merged?
        params[:merged].present?
      end

      def merged_by
        params[:merged_by]
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
    end
  end
end
