class Github::Issue < ApplicationRecord
  extend Mandate::Memoize

  serialize :data, JSON

  memoize
  def data
    super.deep_symbolize_keys
  end
end
