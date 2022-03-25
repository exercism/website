class User
  class ReputationToken
    class AwardForIssue
      include Mandate

      initialize_with :params

      def call
        return unless label_change?
        return unless reputation_level
        return unless author
        return unless author.maintainer? || author.admin?

        token = User::ReputationToken::Create.(
          author,
          :issue_author,
          level: reputation_level,
          repo: params[:repo],
          issue_node_id: params[:node_id],
          issue_number: params[:number],
          issue_title: params[:title],
          external_url: params[:html_url],
          opened_at: params[:opened_at]
        )
        token&.update!(level: reputation_level)
      end

      private
      def label_change?
        %w[labeled unlabeled].include?(params[:action])
      end

      memoize
      def reputation_level
        # Sort descendingly to award greatest possible reputation
        %i[massive large].find do |type|
          params[:labels].include?(Github::IssueLabel.for_type(:size, type))
        end
      end

      memoize
      def author
        User.find_by(github_username: params[:opened_by_username])
      end
    end
  end
end
