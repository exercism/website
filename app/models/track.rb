class Track < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  friendly_id :slug, use: [:history]

  # TODO: Pre-launch: remove dependent: :destroy
  has_many :concepts, class_name: "::Concept", dependent: :destroy
  has_many :exercises, dependent: :destroy
  has_many :solutions, through: :exercises
  has_many :user_tracks, dependent: :destroy

  has_many :concept_exercises # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :practice_exercises # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :documents # rubocop:disable Rails/HasManyOrHasOneDependent

  # TODO: Pre-launch: remove dependent: :destroy
  has_many :tasks, class_name: "Github::Task", dependent: :destroy

  scope :active, -> { where(active: true) }

  delegate :key_features, :about, :snippet,
    :indent_style, :indent_size,
    to: :git

  delegate :head_sha, to: :git, prefix: :git
  delegate :debugging_instructions, to: :git

  def self.for!(param)
    return param if param.is_a?(Track)
    return find_by!(id: param) if param.is_a?(Numeric)

    find_by!(slug: param)
  end

  def to_param
    slug
  end

  memoize
  def git
    Git::Track.new(synced_to_git_sha, repo_url:)
  end

  memoize
  def tutorial_exercise
    exercises.find_by(slug: "hello-world")
  end

  memoize
  def num_contributors
    User::ReputationPeriod.where(
      period: :forever,
      category: :any,
      about: :track,
      track_id: id
    ).count
  end

  memoize
  def top_contributors
    User::ReputationPeriod::Search.(track_id: id)
  end

  memoize
  def num_code_contributors
    User::ReputationPeriod.where(
      period: :forever,
      category: %i[building maintaining authoring],
      about: :track,
      track_id: id
    ).select(:user_id).distinct.count
  end

  memoize
  def num_mentors
    User::TrackMentorship.
      where(track_id: id).
      select(:user_id).
      distinct.
      count
  end

  def icon_url
    "#{Exercism.config.website_icons_host}/tracks/#{slug}.svg"
  end

  def highlightjs_language
    git.highlightjs_language || slug
  end

  def average_test_duration
    git.average_test_duration.round + INFRASTRUCTURE_DURATION_S
  end

  def accessible_by?(user)
    active || user&.maintainer? || user&.admin?
  end

  CATGEORIES = {
    paradigm: "Paradigm",
    typing: "Typing",
    execution_mode: "Execution mode",
    platform: "Platform",
    runtime: "Runtime",
    used_for: "Used for"
  }.with_indifferent_access.freeze

  TAGS = {
    paradigm: {
      declarative: "Declarative",
      functional: "Functional",
      imperative: "Imperative",
      logic: "Logic",
      object_oriented: "Object-oriented",
      procedural: "Procedural"
    },
    typing: {
      static: "Static",
      dynamic: "Dynamic",
      strong: "Strong",
      weak: "Weak"
    },
    execution_mode: {
      compiled: "Compiled",
      interpreted: "Interpreted"
    },
    platform: {
      windows: "Windows",
      mac: "Mac OSX",
      linux: "Linux",
      ios: "iOS",
      android: "Android",
      web: "Web Browser"
    },
    runtime: {
      standalone_executable: "Standalone executable",
      language_specific: "Language-specific runtime",
      clr: "Common Language Runtime (.NET)",
      jvm: "JVM (Java)",
      beam: "BEAM (Erlang)"
    },
    used_for: {
      artificial_intelligence: "Artificial Intelligence",
      backends: "Backends",
      cross_platform_development: "Cross-platform development",
      embedded_systems: "Embedded systems",
      financial_systems: "Financial systems",
      frontends: "Frontends",
      games: "Games",
      guis: "GUIs",
      mobile: "Mobile",
      robotics: "Robotics",
      scientific_calculations: "Scientific calculations",
      scripts: "Scripts",
      web_development: "Web development"
    }
  }.with_indifferent_access.freeze

  INFRASTRUCTURE_DURATION_S = 1
end
