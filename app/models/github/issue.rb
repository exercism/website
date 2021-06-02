class Github::Issue < ApplicationRecord
  extend Mandate::Memoize

  enum status: { open: 0, closed: 1 }, _prefix: true

  has_many :labels,
    dependent: :destroy,
    inverse_of: :issue,
    class_name: "Github::IssueLabel",
    foreign_key: "github_issue_id"

  belongs_to :track, optional: true

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

  before_validation on: :create do
    update_track unless track
  end

  before_validation :update_track, on: :update

  def status
    super.to_sym
  end

  private
  def update_track
    normalized_repo = repo.gsub(/-(test-runner|analyzer|representer)$/, '')
    self.track_id = Track.where(repo_url: "https://github.com/#{normalized_repo}").pick(:id)
  end
end
