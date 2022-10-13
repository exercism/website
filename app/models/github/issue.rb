class Github::Issue < ApplicationRecord
  enum status: { open: 0, closed: 1 }, _prefix: true

  has_many :labels,
    dependent: :destroy,
    inverse_of: :issue,
    class_name: "Github::IssueLabel",
    foreign_key: "github_issue_id"

  def status = super.to_sym

  def github_url = "https://github.com/#{repo}/issues/#{number}"
end
