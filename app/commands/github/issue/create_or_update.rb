module Github
  class Issue
    class CreateOrUpdate
      include Mandate

      initialize_with :node_id, :attributes

      def call
        issue = ::Github::Issue.create_or_find_by!(node_id:) do |i|
          i.number = attributes[:number]
          i.title = attributes[:title]
          i.status = status
          i.repo = attributes[:repo]
          i.opened_at = attributes[:opened_at]
          i.opened_by_username = attributes[:opened_by_username]
        end

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
      def labels(issue)
        attributes[:labels].to_a.map do |label|
          Github::IssueLabel::CreateOrUpdate.(issue, label)
        end
      end

      def status
        attributes[:state].downcase.to_sym
      end
    end
  end
end
