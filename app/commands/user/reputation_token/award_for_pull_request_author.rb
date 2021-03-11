class User
  class ReputationToken
    class AwardForPullRequestAuthor
      include Mandate

      initialize_with :action, :github_username, :params

      def call
        return unless merged?

        user = User.find_by(github_username: github_username)

        # TODO: decide what to do with user that cannot be found
        Rails.logger.error "Missing author: #{github_username}" unless user
        return unless user

        token = User::ReputationToken::Create.(
          user,
          :code_contribution,
          level: author_reputation_level,
          repo: params[:repo],
          pr_id: params[:pr_id],
          pr_number: params[:pr_number],
          external_link: params[:html_url]
        )
        token.update!(level: author_reputation_level)
      end

      private
      def merged?
        params[:merged].present?
      end

      def author_reputation_level
        return :major if params[:labels].include?('reputation/contributed_code/major')
        return :minor if params[:labels].include?('reputation/contributed_code/minor')

        :regular
      end
    end
  end
end
