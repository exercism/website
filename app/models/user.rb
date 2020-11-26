class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable,
    :confirmable, :validatable,
    :omniauthable, omniauth_providers: [:github]
  has_many :auth_tokens, dependent: :destroy

  has_many :user_tracks, dependent: :destroy
  has_many :tracks, through: :user_tracks
  has_many :solutions, dependent: :destroy
  has_many :submissions, through: :solutions, dependent: :destroy
  has_many :iterations, through: :solutions

  has_many :activities, class_name: "User::Activity", dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :mentor_discussion_posts, as: :author, dependent: :destroy

  has_many :reputation_acquisitions, class_name: "User::ReputationAcquisition", dependent: :destroy

  has_many :badges, dependent: :destroy

  belongs_to :featured_user_badge, class_name: "User::Badge", optional: true
  has_one :featured_badge, through: :featured_user_badge

  def self.for!(param)
    return param if param.is_a?(User)
    return find_by!(id: param) if param.is_a?(Numeric)

    find_by!(handle: param)
  end

  def self.from_omniauth(auth)
    User.new(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: Devise.friendly_token[0, 20],
      name: auth.info.name,
      handle: auth.info.nickname
    ).tap do |user|
      user.skip_confirmation!
      user.save!
    end
  end

  def reputation(track_slug: nil, category: nil)
    raise if track_slug && category

    category = "track_#{track_slug}" if track_slug

    q = reputation_acquisitions
    q.where!(category: category) if category
    q.sum(:amount)
  end

  def joined_track?(track)
    !!UserTrack.for(self, track)
  end

  def has_badge?(slug)
    type = Badge.slug_to_type(slug)
    badges.where(type: type).exists?
  end

  # TODO: This needs fleshing out for mentors
  def may_view_solution?(solution)
    id == solution.user_id
  end
end
