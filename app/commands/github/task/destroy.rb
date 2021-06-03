module Github
  class Task
    class Destroy
      include Mandate

      initialize_with :issue_url

      def call
        task = ::Github::Task.find_by(issue_url: issue_url)
        task&.destroy
      end
    end
  end
end
