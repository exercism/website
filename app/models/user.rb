class User < ApplicationRecord
  include User::Roles
  extend Mandate::Memoize

  SYSTEM_USER_ID = 1
  GHOST_USER_ID = 720_036

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable,
    :confirmable, :validatable,
    :omniauthable, omniauth_providers: [:github]

  has_many :auth_tokens, dependent: :destroy

  has_one :profile, dependent: :destroy
  has_one :communication_preferences, dependent: :destroy

  has_many :user_tracks, dependent: :destroy
  has_many :tracks, through: :user_tracks
  has_many :solutions, dependent: :destroy
  has_many :submissions, through: :solutions, dependent: :destroy
  has_many :iterations, through: :solutions

  has_many :solution_mentor_discussions, through: :solutions, source: :mentor_discussions
  has_many :solution_mentor_requests, through: :solutions, source: :mentor_requests

  has_many :activities, class_name: "User::Activity", dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :mentor_discussions, foreign_key: :mentor_id,
    inverse_of: :mentor,
    dependent: :destroy,
    class_name: "Mentor::Discussion"
  has_many :mentor_discussion_posts, inverse_of: :author,
    dependent: :destroy,
    class_name: "Mentor::DiscussionPost"
  has_many :mentor_testimonials, foreign_key: :mentor_id,
    inverse_of: :mentor,
    dependent: :destroy,
    class_name: "Mentor::Testimonial"
  has_many :provided_testimonials, foreign_key: :student_id,
    inverse_of: :student,
    dependent: :destroy,
    class_name: "Mentor::Testimonial"

  has_many :student_relationships, class_name: "Mentor::StudentRelationship",
    foreign_key: :mentor_id, inverse_of: :mentor, dependent: :destroy
  has_many :mentor_relationships, class_name: "Mentor::StudentRelationship",
    foreign_key: :student_id, inverse_of: :student, dependent: :destroy

  has_many :reputation_tokens, class_name: "User::ReputationToken", dependent: :destroy
  has_many :reputation_periods, class_name: "User::ReputationPeriod", dependent: :destroy

  has_many :acquired_badges, dependent: :destroy
  has_many :badges, through: :acquired_badges
  has_many :revealed_badges, -> { User::AcquiredBadge.revealed }, through: :acquired_badges, source: :badge

  has_many :authorships, class_name: "Exercise::Authorship", dependent: :destroy
  has_many :authored_exercises, through: :authorships, source: :exercise

  has_many :contributorships, class_name: "Exercise::Contributorship", dependent: :destroy
  has_many :contributed_exercises, through: :contributorships, source: :exercise
  has_many :scratchpad_pages, dependent: :destroy

  has_many :solution_comments, dependent: :destroy, class_name: "Solution::Comment", inverse_of: :author
  has_many :solution_stars, dependent: :destroy, class_name: "Solution::Star"

  has_many :track_mentorships, dependent: :destroy
  has_many :mentored_tracks, through: :track_mentorships, source: :track

  has_many :mentor_locks,
    class_name: "Mentor::RequestLock",
    foreign_key: :locked_by_id,
    inverse_of: :locked_by,
    dependent: :destroy

  has_many :dismissed_introducers, dependent: :destroy

  has_many :donation_subscriptions, class_name: "Donations::Subscription", dependent: :nullify
  has_many :donation_payments, class_name: "Donations::Payment", dependent: :nullify

  has_many :team_memberships, class_name: "ContributorTeam::Membership", dependent: :destroy
  has_many :teams, through: :team_memberships, source: :team

  has_many :problem_reports, dependent: :destroy

  # TODO: Validate presence of name

  validates :handle, uniqueness: { case_sensitive: false }, handle_format: true

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [200, 200]
  end

  before_create do
    self.name = self.handle if self.name.blank?
  end

  after_create_commit do
    create_communication_preferences

    after_confirmation if confirmed?
  end

  def after_confirmation
    User::Notification::CreateEmailOnly.(self, :joined_exercism, {})
  end

  def self.for!(param)
    return param if param.is_a?(User)
    return find_by!(id: param) if param.is_a?(Numeric)

    find_by!(handle: param)
  end

  def to_param
    handle
  end

  def pronoun_parts
    a = pronouns.to_s.split("/")
    a.fill("", a.length...3)
  end

  def pronoun_parts=(parts)
    parts = parts.sort_by(&:first).map(&:second) if parts.is_a?(Hash)
    self.pronouns = parts.map(&:strip).join("/")
  end

  def create_auth_token!
    transaction do
      auth_tokens.update_all(active: false)
      auth_tokens.create!(active: true)
    end
  end

  def auth_token
    auth_tokens.active.first.try(&:token)
  end

  def formatted_reputation(*args)
    rep = reputation(*args)
    User::FormatReputation.(rep)
  end

  def active_subscription
    donation_subscriptions.active.last
  end

  memoize
  def active_donation_subscription_amount_in_cents
    donation_subscriptions.active.last&.amount_in_cents
  end

  memoize
  def total_subscription_donations_in_dollars
    donation_payments.subscription.sum(:amount_in_cents) / BigDecimal(100)
  end

  memoize
  def total_one_off_donations_in_dollars
    total_donated_in_dollars - total_subscription_donations_in_dollars
  end

  memoize
  def total_donated_in_dollars
    total_donated_in_cents / BigDecimal(100)
  end

  def reputation(track_slug: nil, category: nil)
    return super() unless track_slug || category

    raise if track_slug && category

    category = "track_#{track_slug}" if track_slug

    q = reputation_tokens
    q.where!(category:) if category
    q.sum(:value)
  end

  def joined_track?(track)
    !UserTrack.for(self, track).external?
  end

  def unrevealed_badges
    acquired_badges.unrevealed.joins(:badge)
  end

  def has_badge?(slug)
    badge = Badge.find_by_slug!(slug) # rubocop:disable Rails/DynamicFindBy
    acquired_badges.where(badge_id: badge.id).exists?
  end

  def featured_badges
    revealed_badges.ordered_by_rarity.limit(5)
  end

  def recently_used_cli?
    solutions.where('downloaded_at >= ?', Time.current - 30.days).exists?
  end

  # TODO: Remove this if there have not been any bugsnags
  def may_view_solution?(solution)
    begin
      raise "User#may_view_solution? is deprecated"
    rescue StandardError => e
      Bugsnag.notify(e)
    end

    solution.viewable_by?(self)
  end

  def onboarded?
    accepted_privacy_policy_at.present? &&
      accepted_terms_at.present?
  end

  def has_avatar_url?
    super.presence? || avatar.attached?
  end

  def avatar_url
    return Rails.application.routes.url_helpers.url_for(avatar.variant(:thumb)) if avatar.attached?

    super.presence || "#{Exercism.config.website_icons_host}/placeholders/user-avatar.svg"
  end

  def has_avatar?
    avatar.attached? || self[:avatar_url].present?
  end

  # TODO
  def languages_spoken
    %w[english spanish]
  end

  def mentor?
    became_mentor_at.present?
  end

  def system?
    id == SYSTEM_USER_ID
  end

  def ghost?
    id == GHOST_USER_ID
  end

  def dismiss_introducer!(slug)
    dismissed_introducers.create_or_find_by!(slug:)
  end

  def introducer_dismissed?(slug)
    dismissed_introducers.where(slug:).exists?
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
