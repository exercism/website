class Github::Issue < ApplicationRecord
  enum status: { open: 0, closed: 1 }, _prefix: true

  has_many :labels,
    dependent: :destroy,
    inverse_of: :issue,
    class_name: "Github::IssueLabel",
    foreign_key: "github_issue_id"

  scope :with_label, lambda { |label|
    where(
      id: Github::IssueLabel.
        where('github_issue_id = github_issues.id AND label = ?', label).
        select(:github_issue_id)
    )
  }

  scope :without_label, lambda { |label|
    where.not(
      id: Github::IssueLabel.
        where('github_issue_id = github_issues.id AND label = ?', label).
        select(:github_issue_id)
    )
  }

  def status
    super.to_sym
  end
end
