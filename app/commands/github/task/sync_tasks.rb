module Github
  class Task
    class SyncTasks
      include Mandate

      def call
        issues.each do |issue|
          SyncTask.(issue)
        rescue StandardError => e
          Rails.logger.error "Error syncing task for issue #{issue.repo}/#{issue.number}: #{e}"
        end
      end

      private
      def issues
        Github::Issue.left_joins(:labels)
      end
    end
  end
end
