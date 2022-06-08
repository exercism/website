module Github
  class IssueLabel
    class CreateOrUpdate
      include Mandate

      initialize_with :issue, :label

      def call
        ::Github::IssueLabel.create_or_find_by!(issue:, name: label)
      end
    end
  end
end
