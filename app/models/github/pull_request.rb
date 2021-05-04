class Github::PullRequest < ApplicationRecord
  extend Mandate::Memoize

  serialize :data, JSON

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
