module Github
  class Issue
    class CreateOrUpdate
      include Mandate

      initialize_with :node_id, :attributes

      def call
        @issue = ::Github::Issue.create_or_find_by!(node_id:) do |i|
          i.number = attributes[:number]
          i.title = attributes[:title]
          i.status = status
          i.repo = attributes[:repo]
          i.opened_at = attributes[:opened_at]
          i.opened_by_username = attributes[:opened_by_username]
        end

        log_metric! if issue.just_created?

        issue.update!(
          number: attributes[:number],
          title: attributes[:title],
          status:,
          repo: attributes[:repo],
          opened_at: attributes[:opened_at],
          opened_by_username: attributes[:opened_by_username],
          labels: labels(issue)
        )

        issue
      end

      private
      attr_reader :issue

      def labels(issue)
        attributes[:labels].to_a.map do |label|
          Github::IssueLabel::CreateOrUpdate.(issue, label)
        end
      end

      def status = attributes[:state].downcase.to_sym

      def log_metric!
        LogMetricJob.perform_later(:open_issue, issue.opened_at, track:, user: opened_by_username)
      end

      def repo_url = "https://github.com/#{issue.repo}"
      def track = Track.find_by(repo_url:)
      def opened_by_username = User.find_by(github_username: issue.opened_by_username)
    end
  end
end
