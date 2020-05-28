class User < ApplicationRecord
  has_many :solutions
  has_many :notifications

  has_many :reputation_acquisitions, class_name: "User::ReputationAcquisition"

  def self.for!(param)
    return param if param.is_a?(User)
    return find_by_id!(param) if param.is_a?(Numeric)
    find_by_handle!(param)
  end

  def reputation(track_slug:nil, category:nil)
    raise if track_slug && category
    category = "track_#{track_slug}" if track_slug

    q = reputation_acquisitions
    q.where!(category: category) if category
    q.sum(:amount)
  end

  def available_credits
    credits
  end
end
