class Track < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize
  friendly_id :slug, use: [:history]

  has_many :concepts, class_name: "Track::Concept", dependent: :destroy
  has_many :exercises, dependent: :destroy

  has_many :concept_exercises # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :practice_exercises # rubocop:disable Rails/HasManyOrHasOneDependent

  scope :active, -> { where(active: true) }

  delegate :test_regexp, :ignore_regexp, :key_features, :about, :snippet,
    to: :git

  delegate :head_sha, to: :git, prefix: :git

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
    # TODO: Slug can be removed from this
    # once we're out of the monorepo
    Git::Track.new(slug, synced_to_git_sha, repo_url: repo_url)
  end

  # TODO: Set this properly
  def icon_name
    "sample-track"
  end

  # TODO: Set this properly
  def icon_url
    "https://assets.exercism.io/tracks/ruby-hex-white.png"
  end

  # TODO: Create mapping for Highlight.JS, otherwise use slug
  def highlightjs_language
    slug
  end

  TAGS = {
    "Paradigm": {
      declarative: "Declarative",
      functional: "Functional",
      imperative: "Imperative",
      logic: "Logic",
      object_oriented: "Object-oriented",
      procedural: "Procedural"
    },
    "Typing": {
      static: "Static",
      dynamic: "Dynamic",
      strong: "Strong",
      weak: "Weak"
    },
    "Execution mode": {
      compiled: "Compiled",
      interpreted: "Interpreted"
    },
    "Platform": {
      windows: "Windows",
      mac: "Mac OSX",
      linux: "Linux",
      ios: "iOS",
      android: "Android",
      web: "Web Browser"
    },
    "Runtime": {
      standalone_executable: "Standalone executable",
      language_specific: "Language-specific runtime",
      clr: "Common Language Runtime (.NET)",
      jvm: "JVM (Java)",
      beam: "BEAM (Erlang)"
    },
    "Used for": {
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
  }.freeze
end
