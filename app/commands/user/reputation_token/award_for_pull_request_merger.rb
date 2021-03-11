class User
  class ReputationToken
    class AwardForPullRequestMerger
      include Mandate

      initialize_with :action, :github_username, :params

      def call
        return unless merged?

        user = User.find_by(github_username: params[:merged_by])

        # TODO: decide what to do with user that cannot be found
        Rails.logger.error "Missing merged by user: #{params[:merged_by]}" unless user
        return unless user

        User::ReputationToken::Create.(
          user,
          :code_merge,
          repo: params[:repo],
          pr_id: params[:pr_id],
          pr_number: params[:pr_number],
          external_link: params[:html_url]
        )
      end

      private
      def merged?
        params[:merged].present?
      end
    end
  end
end
