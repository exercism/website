class User < ApplicationRecord
  has_many :solutions
  has_many :reputation_acquisitions, class_name: "User::ReputationAcquisition"

  def self.for!(param)
    return param if param.is_a?(User)
    return find_by_id!(param) if param.is_a?(Numeric)
    find_by_handle!(param)
  end

  def reputation(track_slug:nil, category:nil)
    q = reputation_acquisitions
    q.where!(category: category) if category
    q.where!(category: "track_#{track_slug}") if track_slug
    q.sum(:amount)
  end
end
