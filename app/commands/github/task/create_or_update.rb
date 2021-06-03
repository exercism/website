module Github
  class Task
    class CreateOrUpdate
      include Mandate

      initialize_with :issue_url, :attributes

      def call
        task = ::Github::Task.create_or_find_by!(issue_url: issue_url) do |t|
          t.title = attributes[:title]
          t.opened_at = attributes[:opened_at]
          t.opened_by_username = attributes[:opened_by_username]
          t.action = attributes[:action]
          t.knowledge = attributes[:knowledge]
          t.area = attributes[:area]
          t.size = attributes[:size]
          t.type = attributes[:type]
        end

        task.update!(
          title: attributes[:title],
          opened_at: attributes[:opened_at],
          opened_by_username: attributes[:opened_by_username],
          action: attributes[:action],
          knowledge: attributes[:knowledge],
          area: attributes[:area],
          size: attributes[:size],
          type: attributes[:type]
        )

        task
      end
    end
  end
end
