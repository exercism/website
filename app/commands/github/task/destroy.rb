module Github
  class Task
    class Destroy
      include Mandate

      initialize_with :issue_url

      def call
        Github::Task.where(issue_url:).destroy_all
      end
    end
  end
end
