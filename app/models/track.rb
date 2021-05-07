class Track < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  friendly_id :slug, use: [:history]

  # TODO: Pre-launch: remove dependent: :destroy
  has_many :concepts, class_name: "Track::Concept", dependent: :destroy

  # TODO: Pre-launch: remove dependent: :destroy
  has_many :exercises, dependent: :destroy

  has_many :concept_exercises # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :practice_exercises # rubocop:disable Rails/HasManyOrHasOneDependent

  scope :active, -> { where(active: true) }

  delegate :test_regexp, :ignore_regexp, :key_features, :about, :snippet,
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
    Git::Track.new(synced_to_git_sha, repo_url: repo_url)
  end

  def course?
    git.has_concept_exercises?
  end

  # TODO: Read this from a cache and update periodically
  def num_contributors
    User::ReputationToken.where(track_id: id).distinct.select(:user_id).count
  end

  def top_10_contributors
    user_ids = User::ReputationToken.where(track_id: id).
      group(:user_id).
      select("user_id, COUNT(*) as c").
      order("c DESC").
      limit(10).map(&:user_id)

    User.where(id: user_ids).
      order(Arel.sql("FIND_IN_SET(id, '#{user_ids.join(',')}')")).
      to_a
  end

  def num_code_contributors
    User::ReputationToken.
      where(track_id: id, type: User::ReputationTokens::CodeContributionToken).
      select(:user_id).
      distinct.
      count
  end

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

  def ace_language
    # TODO: remove || slug once all tracks have updated their config.json
    git.ace_editor_language || slug
  end

  def highlightjs_language
    # TODO: remove || slug once all tracks have updated their config.json
    git.highlightjs_language || slug
  end

  # TODO: Set this properly
  def median_wait_time
    "6 hrs"
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
end
