class User
  class ReputationToken
    class AwardForPullRequestAuthor
      include Mandate

      initialize_with :params

      def call
        return unless has_author?
        return unless merged?
        return if v3_migration_pr?

        user = User.find_by(github_username: params[:author_username])

        unless user
          # TODO: decide what to do with user that cannot be found
          Rails.logger.error "Missing author: #{params[:author_username]}"
          return
        end

        token = User::ReputationToken::Create.(
          user,
          :code_contribution,
          level: reputation_level,
          repo: params[:repo],
          pr_node_id: params[:node_id],
          pr_number: params[:number],
          pr_title: params[:title],
          external_url: params[:html_url]
        )
        token.update!(level: reputation_level)
      end

      private
      def merged?
        params[:merged].present?
      end

      def has_author?
        params[:author_username].present?
      end

      def v3_migration_pr?
        return false unless params[:author_username] == 'ErikSchierboom'

        params[:title].start_with?('[v3]') ||
          params[:labels].include?('v3-migration 🤖')
      end

      def reputation_level
        return :major if params[:labels].include?('reputation/contributed_code/major')
        return :minor if params[:labels].include?('reputation/contributed_code/minor')

        :regular
      end
    end
  end
end
