class User < ApplicationRecord
  has_many :solutions, dependent: :destroy
  has_many :iterations, through: :solutions, dependent: :destroy

  has_many :notifications, dependent: :destroy

  has_many :reputation_acquisitions, class_name: "User::ReputationAcquisition", dependent: :destroy

  has_many :badges, dependent: :destroy

  belongs_to :featured_user_badge, class_name: "User::Badge", optional: true
  has_one :featured_badge, through: :featured_user_badge

  def self.for!(param)
    return param if param.is_a?(User)
    return find_by!(id: param) if param.is_a?(Numeric)

    find_by!(handle: param)
  end

  def reputation(track_slug: nil, category: nil)
    raise if track_slug && category

    category = "track_#{track_slug}" if track_slug

    q = reputation_acquisitions
    q.where!(category: category) if category
    q.sum(:amount)
  end

  def has_badge?(slug)
    type = Badge.slug_to_type(slug)
    badges.where(type: type).exists?
  end
end
