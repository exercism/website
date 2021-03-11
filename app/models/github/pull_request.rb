class Github::PullRequest < ApplicationRecord
  extend Mandate::Memoize

  has_many :reviews,
    dependent: :destroy,
    inverse_of: :pull_request,
    class_name: "Github::PullRequestReview",
    foreign_key: "github_pull_request_id"

  memoize
  def data
    super.deep_symbolize_keys
  end
end
