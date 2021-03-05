class Git::PullRequest < ApplicationRecord
  extend Mandate::Memoize

  has_many :reviews,
    dependent: :destroy,
    inverse_of: :pull_request,
    class_name: "Git::PullRequestReview",
    foreign_key: "git_pull_request_id"

  memoize
  def data
    event.deep_symbolize_keys
  end
end
