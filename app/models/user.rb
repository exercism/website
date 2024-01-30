class User < ApplicationRecord
  extend Mandate::Memoize

  SYSTEM_USER_ID = 1
  GHOST_USER_ID = 720_036
  IHID_USER_ID = 1530
  MIN_REP_TO_MENTOR = 20

  enum flair: {
    founder: 0,
    staff: 1,
    insider: 2,
    lifetime_insider: 3
  }, _prefix: "show", _suffix: "flair"

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable,
    :confirmable, :validatable,
    :omniauthable, omniauth_providers: %i[github discord]

  has_many :auth_tokens, dependent: :destroy

  has_one :data, dependent: :destroy, class_name: "User::Data", autosave: true
  has_one :profile, dependent: :destroy
  has_one :preferences, dependent: :destroy
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

  has_many :mentor_discussion_solutions, through: :mentor_discussions, source: :solution
  has_many :mentor_request_solutions, through: :mentor_requests, source: :solution

  has_many :submission_representations, class_name: "Submission::Representation",
    foreign_key: :mentored_by_id, inverse_of: :mentored_by, dependent: :destroy

  has_many :student_relationships, class_name: "Mentor::StudentRelationship",
    foreign_key: :mentor_id, inverse_of: :mentor, dependent: :destroy
  has_many :mentor_relationships, class_name: "Mentor::StudentRelationship",
    foreign_key: :student_id, inverse_of: :student, dependent: :destroy

  has_many :reputation_tokens, class_name: "User::ReputationToken", dependent: :destroy
  has_many :reputation_periods, class_name: "User::ReputationPeriod", dependent: :destroy

  has_many :acquired_badges, dependent: :destroy
  has_many :badges, through: :acquired_badges
  has_many :revealed_badges, -> { User::AcquiredBadge.revealed }, through: :acquired_badges, source: :badge

  has_many :acquired_trophies, class_name: "UserTrack::AcquiredTrophy", dependent: :destroy
  has_many :trophies, through: :acquired_trophies

  has_many :authorships, class_name: "Exercise::Authorship", dependent: :destroy
  has_many :authored_exercises, through: :authorships, source: :exercise

  has_many :contributorships, class_name: "Exercise::Contributorship", dependent: :destroy
  has_many :contributed_exercises, through: :contributorships, source: :exercise

  has_many :article_authorships, class_name: "Exercise::Article::Authorship", dependent: :destroy
  has_many :authored_articles, through: :article_authorships, source: :article

  has_many :article_contributorships, class_name: "Exercise::Article::Contributorship", dependent: :destroy
  has_many :contributed_articles, through: :article_contributorships, source: :article

  has_many :approach_authorships, class_name: "Exercise::Approach::Authorship", dependent: :destroy
  has_many :authored_approaches, through: :approach_authorships, source: :approach

  has_many :approach_contributorships, class_name: "Exercise::Approach::Contributorship", dependent: :destroy
  has_many :contributed_approaches, through: :approach_contributorships, source: :approach

  has_many :approach_introduction_authorships, class_name: "Exercise::Approach::Introduction::Authorship", dependent: :destroy
  has_many :authored_approach_introduction_exercises, through: :approach_introduction_authorships, source: :exercise
  has_many :approach_introduction_contributorships, class_name: "Exercise::Approach::Introduction::Contributorship",
    dependent: :destroy
  has_many :contributed_approach_introduction_exercises, through: :approach_introduction_contributorships, source: :exercise

  has_many :scratchpad_pages, dependent: :destroy

  has_many :solution_comments, dependent: :destroy, class_name: "Solution::Comment", inverse_of: :author
  has_many :solution_stars, dependent: :destroy, class_name: "Solution::Star"
  has_many :solution_tags, dependent: :destroy, class_name: "Solution::Tag"

  has_many :track_mentorships, dependent: :destroy
  has_many :mentored_tracks, through: :track_mentorships, source: :track

  has_many :mentor_locks,
    class_name: "Mentor::RequestLock",
    foreign_key: :locked_by_id,
    inverse_of: :locked_by,
    dependent: :destroy

  has_many :dismissed_introducers, dependent: :destroy

  has_many :subscriptions, class_name: "Payments::Subscription", dependent: :nullify
  has_many :payments, class_name: "Payments::Payment", dependent: :nullify

  has_many :problem_reports, dependent: :destroy

  has_many :cohort_memberships, dependent: :destroy

  has_many :github_team_memberships,
    class_name: "Github::TeamMember",
    primary_key: :uid,
    inverse_of: :user,
    dependent: :destroy

  has_many :challenges, dependent: :destroy
  has_many :watched_videos, class_name: "User::WatchedVideo", dependent: :destroy

  scope :random, -> { order('RAND()') }

  scope :with_data, -> { joins(:data) }
  scope :insiders, -> { with_data.where(user_data: { insiders_status: %i[active active_lifetime] }) }

  # TODO: Validate presence of name
  validates :handle, uniqueness: { case_sensitive: false }, handle_format: true, length: { maximum: 190 }
  validates :name, length: { maximum: 255 }
  validates :email, length: { maximum: 190 }
  validates :pronouns, length: { maximum: 255 }
  validates :location, length: { maximum: 255 }

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [200, 200]
  end

  after_initialize do
    build_data if new_record?
  end

  before_create do
    self.name = self.handle if self.name.blank?
  end

  after_create_commit do
    create_preferences
    create_communication_preferences

    after_confirmation if confirmed?
  end

  after_update_commit do
    reverify_email! if previous_changes.key?('email')
  end

  # If we don't know about this record, maybe the
  # user's data record has it instead?
  def method_missing(name, *args)
    super
  rescue NameError
    raise unless data.respond_to?(name)

    data.send(name, *args)
  end

  def respond_to_missing?(name, *args)
    super || data.respond_to?(name)
  end

  # Don't rely on respond_to_missing? which n+1s a data record
  # https://tenderlovemaking.com/2011/06/28/til-its-ok-to-return-nil-from-to_ary.html
  def to_ary
    nil
  end

  def after_confirmation
    User::Notification::CreateEmailOnly.(self, :joined_exercism)
  end

  def self.for!(param)
    return param if param.is_a?(User)
    return find_by!(id: param) if param.is_a?(Numeric)

    find_by!(handle: param)
  end

  def to_param = handle

  def pronoun_parts
    a = pronouns.to_s.split("/")
    a.size == 3 && a.exclude?('') ? a : nil
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

  memoize
  def donated_in_last_35_days?
    payments.where('created_at > ?', Time.current - 35.days).exists?
  end

  memoize
  def current_subscription? = current_subscription.present?

  memoize
  def current_subscription = subscriptions.where(status: %i[active overdue]).last

  memoize
  def total_subscription_donations_in_dollars
    payments.subscription.sum(:amount_in_cents) / BigDecimal(100)
  end

  memoize
  def total_one_off_donations_in_dollars = total_donated_in_dollars - total_subscription_donations_in_dollars

  memoize
  def total_donated_in_dollars
    total_donated_in_cents / BigDecimal(100)
  end

  def reputation_for_track(track)
    User::ReputationToken.where(
      track:,
      user_id: id
    ).sum(:value)
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

  # Don't memoize this as it can change when someone uploads their photo
  def avatar_url
    "#{Exercism.config.website_avatars_host}/#{id}/#{version}"
  end

  def has_avatar?
    avatar.attached? || self[:avatar_url].present?
  end

  def may_receive_emails?
    return false if disabled?
    return false if email.ends_with?("users.noreply.github.com")
    return false if email_status_invalid?
    return false if system?
    return false if ghost?

    true
  end

  # TODO
  def languages_spoken
    %w[english spanish]
  end

  def system? = id == SYSTEM_USER_ID
  def ghost? = id == GHOST_USER_ID

  def dismiss_introducer!(slug)
    dismissed_introducers.create_or_find_by!(slug:)
  end

  def introducer_dismissed?(slug)
    dismissed_introducers.where(slug:).exists?
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def reverify_email!
    email_status_unverified!
    User::VerifyEmail.defer(self)
  end

  memoize
  def profile? = profile.present?
  def may_create_profile? = reputation >= User::Profile::MIN_REPUTATION

  def confirmed? = super && !disabled? && !blocked?
  def disabled? = !!disabled_at
  def blocked? = User::BlockDomain.blocked?(user: self)

  def github_auth? = uid.present?
  def captcha_required? = !github_auth? && Time.current - created_at < 2.days

  def flair = super&.to_sym

  def automator?(track = nil)
    return true if staff?

    tms = track_mentorships.automator
    tms = tms.where(track:) if track
    tms.exists?
  end

  def trainer?(track = nil)
    return true if staff?
    return false unless super()
    return eligible_for_trainer?(track) if track.present?

    true
  end

  def eligible_for_trainer?(track = nil)
    uts = user_tracks.trainer
    uts = uts.where(track:) if track
    uts.exists?
  end

  def watched_video?(video_provider, video_id)
    watched_videos.where(
      video_provider:, video_id:
    ).exists?
  end
end
