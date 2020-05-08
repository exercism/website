class Track < ApplicationRecord
  def self.for!(param)
    return param if param.is_a?(Track)
    return find_by_id!(param) if param.is_a?(Numeric)
    find_by_slug!(param)
  end
end
