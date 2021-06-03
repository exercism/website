module Github
  class Task
    class SyncTask
      include Mandate

      initialize_with :issue

      def call
        if closed? || claimed?
          destroy_task
        else
          create_or_update_task
        end
      end

      private
      def closed?
        issue.status == :closed
      end

      def claimed?
        issue.labels.any? { |label| label.name == Github::IssueLabel.for_type(:status, :claimed) }
      end

      def create_or_update_task
        Github::Task::CreateOrUpdate.(
          issue.github_url,
          title: issue.title,
          opened_at: issue.opened_at,
          opened_by_username: issue.opened_by_username,
          action: find_label_of_type(:action),
          knowledge: find_label_of_type(:knowledge),
          area: find_label_of_type(:module),
          size: find_label_of_type(:size),
          type: find_label_of_type(:type)
        )
      end

      def destroy_task
        Github::Task::Destroy.(issue.github_url)
      end

      def find_label_of_type(type)
        label = issue.labels.find { |l| l.of_type?(type) }
        label&.value
      end
    end
  end
end
