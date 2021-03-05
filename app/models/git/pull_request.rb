class Git::PullRequest < ApplicationRecord
  extend Mandate::Memoize

  self.table_name = "git_pull_requests"

  memoize
  def data
    event.deep_symbolize_keys
  end
end
