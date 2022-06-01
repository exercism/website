module Github
  class Task
    class CreateOrUpdate
      include Mandate

      initialize_with :issue_url, :attributes

      def call
        task = ::Github::Task.create_or_find_by!(issue_url:) do |t|
          t.attributes = attributes
        end

        task.update!(attributes)
        task
      end
    end
  end
end
