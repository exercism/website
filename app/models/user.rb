class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable,
    :confirmable, :validatable,
    :omniauthable, omniauth_providers: [:github]
  has_many :auth_tokens, dependent: :destroy

  has_one :profile, dependent: :destroy

  has_many :user_tracks, dependent: :destroy
  has_many :tracks, through: :user_tracks
  has_many :solutions, dependent: :destroy
  has_many :submissions, through: :solutions, dependent: :destroy
  has_many :iterations, through: :solutions

  has_many :activities, class_name: "User::Activity", dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :mentor_discussion_posts, as: :author, dependent: :destroy

  has_many :reputation_tokens, class_name: "User::ReputationToken", dependent: :destroy

  has_many :badges, dependent: :destroy

  belongs_to :featured_user_badge, class_name: "User::Badge", optional: true
  has_one :featured_badge, through: :featured_user_badge

  has_many :authorships, class_name: "Exercise::Authorship", dependent: :destroy
  has_many :authored_exercises, through: :authorships, source: :exercise

  has_many :contributorships, class_name: "Exercise::Contributorship", dependent: :destroy
  has_many :contributed_exercises, through: :contributorships, source: :exercise
  has_many :scratchpad_pages, dependent: :destroy

  # TODO: Validate presence of name

  validates :handle, uniqueness: { case_sensitive: false }, handle_format: true

  before_create do
    self.name = self.handle if self.name.blank?
  end

  def self.for!(param)
    return param if param.is_a?(User)
    return find_by!(id: param) if param.is_a?(Numeric)

    find_by!(handle: param)
  end

  # TODO: Move this to the database
  def admin?
    true
  end

  def reputation(track_slug: nil, category: nil)
    return super() unless track_slug || category

    raise if track_slug && category

    category = "track_#{track_slug}" if track_slug

    q = reputation_tokens
    q.where!(category: category) if category
    q.sum(:value)
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

  def onboarded?
    accepted_privacy_policy_at.present? &&
      accepted_terms_at.present?
  end

  # TODO
  def avatar_url
    "https://avatars2.githubusercontent.com/u/5337876?s=460&v=4"
  end

  # TODO
  def bio
    "Developing software / Learning languages / Love to sail"
  end

  # TODO
  def languages_spoken
    %w[english spanish]
  end

  def favorited_by?(mentor)
    relationship = Mentor::StudentRelationship.find_by(student: self, mentor: mentor)

    relationship ? relationship.favorite? : false
  end

  def num_previous_mentor_sessions_with(_user)
    15
  end
end
