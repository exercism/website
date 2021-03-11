class User
  class ReputationToken
    class AwardForPullRequestAuthor
      include Mandate

      initialize_with :params

      def call
        return unless has_author?
        return unless merged?

        user = User.find_by(github_username: params[:author])

        unless user
          # TODO: decide what to do with user that cannot be found
          Rails.logger.error "Missing author: #{params[:author]}"
          return
        end

        token = User::ReputationToken::Create.(
          user,
          :code_contribution,
          level: author_reputation_level,
          repo: params[:repo],
          pr_node_id: params[:pr_node_id],
          pr_number: params[:pr_number],
          external_link: params[:html_url]
        )
        token.update!(level: author_reputation_level)
      end

      private
      def merged?
        params[:merged].present?
      end

      def has_author?
        params[:author].present?
      end

      def author_reputation_level
        return :major if params[:labels].include?('reputation/contributed_code/major')
        return :minor if params[:labels].include?('reputation/contributed_code/minor')

        :regular
      end
    end
  end
end
