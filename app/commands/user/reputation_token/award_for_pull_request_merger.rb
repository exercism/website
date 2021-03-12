class User
  class ReputationToken
    class AwardForPullRequestMerger
      include Mandate

      initialize_with :params

      def call
        return unless merged?
        return if merged_by_author?

        user = User.find_by(github_username: params[:merged_by_username])

        unless user
          # TODO: decide what to do with user that cannot be found
          Rails.logger.error "Missing merged by user: #{params[:merged_by_username]}"
          return
        end

        User::ReputationToken::Create.(
          user,
          :code_merge,
          repo: params[:repo],
          pr_node_id: params[:node_id],
          pr_number: params[:number],
          pr_title: params[:title],
          external_link: params[:html_url]
        )
      end

      private
      def merged?
        params[:merged].present? && params[:merged_by_username].present?
      end

      def merged_by_author?
        params[:merged_by_username] == params[:author_username]
      end
    end
  end
end
