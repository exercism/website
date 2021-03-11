class User
  class ReputationToken
    class AwardForPullRequestMerger
      include Mandate

      initialize_with :params

      def call
        return unless merged?
        return if merged_by_author?

        user = User.find_by(github_username: params[:merged_by])

        unless user
          # TODO: decide what to do with user that cannot be found
          Rails.logger.error "Missing merged by user: #{params[:merged_by]}"
          return
        end

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
        params[:merged].present? && params[:merged_by].present?
      end

      def merged_by_author?
        params[:merged_by] == params[:author]
      end
    end
  end
end
