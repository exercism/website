class Git::PullRequest < ApplicationRecord
  extend Mandate::Memoize

  memoize
  def data
    event.deep_symbolize_keys
  end
end
