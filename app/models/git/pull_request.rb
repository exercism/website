class Git::PullRequest < ApplicationRecord
  extend Mandate::Memoize

  has_many :pull_request_reviews, dependent: :destroy

  memoize
  def data
    event.deep_symbolize_keys
  end
end
