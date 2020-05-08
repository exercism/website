class User < ApplicationRecord
  has_many :solutions

  def self.for!(param)
    return param if param.is_a?(User)
    return find_by_id!(param) if param.is_a?(Numeric)
    find_by_handle!(param)
  end
end
