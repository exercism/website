class Github::IssueLabel < ApplicationRecord
  belongs_to :issue,
    inverse_of: :labels,
    foreign_key: "github_issue_id",
    class_name: "Github::Issue"
end
