class Track < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize
  include Track::BuildStatus
  include HasTranslatedMetadata

  friendly_id :slug, use: [:history]

  # TODO: Pre-launch: remove dependent: :destroy
  has_many :concepts, class_name: "::Concept", dependent: :destroy
  has_many :exercises, dependent: :destroy
  has_many :solutions, through: :exercises
  has_many :submissions, dependent: :destroy
  has_many :representations, class_name: "Exercise::Representation", dependent: :destroy
  has_many :user_tracks, dependent: :destroy
  has_many :mentor_discussions, through: :solutions
  has_many :mentor_requests, class_name: "Mentor::Request", dependent: :destroy
  has_many :reputation_tokens, class_name: "User::ReputationToken", dependent: :destroy

  has_many :concept_exercises # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :practice_exercises # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :documents # rubocop:disable Rails/HasManyOrHasOneDependent

  # TODO: Pre-launch: remove dependent: :destroy
  has_many :tasks, class_name: "Github::Task", dependent: :destroy

  has_many :github_team_members, class_name: "Github::TeamMember", dependent: :destroy

  scope :active, -> { where(active: true) }

  # Tracks whose tests run in the student's browser, on the wasm kernel. Being
  # on this list does two things to the editor: it opts the page in to
  # cross-origin isolation (see CrossOriginIsolation - not free, it blocks any
  # cross-origin iframe, which is why the Insiders upsell links out there), and
  # it sends the editor the exercise files the runner needs.
  #
  # A list here rather than a lookup of the published manifest, because
  # isolating a page is a deliberate per-track decision, not a side effect of
  # something landing in S3.
  CLIENT_SIDE_TEST_RUNNER_SLUGS = %w[jq].freeze
  def client_side_test_runner? = CLIENT_SIDE_TEST_RUNNER_SLUGS.include?(slug)

  delegate :about, :snippet,
    :indent_style, :indent_size, :foregone_exercises,
    to: :git

  delegate :head_sha, to: :git, prefix: :git
  delegate :representations, to: :git, prefix: :mentoring
  delegate :debugging_instructions, :representer_normalizations, to: :git
  delegate :content, :edit_url, to: :mentoring_notes, prefix: :mentoring_notes

  def self.for!(param)
    return param if param.is_a?(Track)
    return find_by!(id: param) if param.is_a?(Numeric)

    find_by!(slug: param)
  end

  def self.for_repo(repo) = find_by(slug: slug_from_repo(repo))
  def self.id_for_repo(repo) = where(slug: slug_from_repo(repo)).pick(:id)

  def self.slug_from_repo(repo)
    name = repo.split('/').last
    TRACK_HELPER_REPOS[name] || name.gsub(TRACK_REPO_PREFIXES, '').gsub(TRACK_REPO_SUFFIXES, '')
  end

  NUM_ACTIVE_TRACKS_CACHE_KEY = 'num_active_tracks'.freeze
  def self.num_active
    @num_active ||= Rails.cache.fetch(NUM_ACTIVE_TRACKS_CACHE_KEY, expires_in: 1.hour) do
      Track.active.count
    end
  end

  def self.reset_num_active!
    Rails.cache.delete(NUM_ACTIVE_TRACKS_CACHE_KEY)
    @num_active = nil
  end

  after_save_commit do
    self.class.reset_num_active!
  end

  def to_param = slug

  def translation_metadata_repo_name = repo_url.split("/").last

  def blurb = translated_metadata("track:blurb", super)
  def translation_expected? = active?

  def key_features
    features = git.key_features
    return features if I18n.locale == I18n.default_locale

    seen = Hash.new(0)
    features.map do |feature|
      id = key_feature_unit_id(feature, seen)
      feature.merge(
        title: translated_metadata("key_feature:#{id}:title", feature[:title]),
        content: translated_metadata("key_feature:#{id}:content", feature[:content])
      )
    end
  end

  memoize
  def git
    Git::Track.new(synced_to_git_sha, repo_url:)
  end

  def key_feature_unit_id(feature, seen)
    icon = feature[:icon].to_s
    icon = "feature" if icon.blank? || icon.include?(":")
    seen[icon] += 1
    seen[icon] > 1 ? "#{icon}~#{seen[icon]}" : icon
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

  memoize
  def trophies
    Track::Trophy.for_track(self)
  end

  def icon_url = Icons::DetermineUrlFor.("tracks/#{slug}.svg", Icons::DetermineUrlFor::MISSING_TRACK_ICON)

  def highlightjs_language
    super || slug
  end

  def average_test_duration
    git.average_test_duration.round + INFRASTRUCTURE_DURATION_S
  end

  def accessible_by?(user)
    active || user&.maintainer? || user&.admin?
  end

  memoize
  def mentoring_notes = Git::Track::MentorNotes.new(slug)

  memoize
  def representer = Git::Representer.new(repo_url: representer_repo_url)

  def test_runner_repo_url = "#{repo_url}-test-runner"
  def representer_repo_url = "#{repo_url}-representer"
  def analyzer_repo_url = "#{repo_url}-analyzer"

  def github_team_name = slug

  # The labels for these live in config/locales/track_tags/en.yml,
  # under track_tags.categories and track_tags.tags.
  TAGS = {
    paradigm: %w[declarative functional imperative logic object_oriented procedural],
    typing: %w[static dynamic gradual strong weak],
    execution_mode: %w[compiled interpreted],
    platform: %w[windows mac linux ios android web],
    runtime: %w[standalone_executable language_specific clr jvm beam],
    used_for: %w[
      artificial_intelligence backends cross_platform_development embedded_systems
      financial_systems frontends games guis mobile robotics scientific_calculations
      scripts web_development
    ]
  }.with_indifferent_access.freeze

  def self.tag_category_label(category) = I18n.t("track_tags.categories.#{category}")

  # Returns nil for a tag that isn't in TAGS.
  def self.tag_label(tag)
    category, value = tag.to_s.split("/", 2)
    return unless TAGS[category]&.include?(value)

    I18n.t("track_tags.tags.#{category}.#{value}")
  end

  INFRASTRUCTURE_DURATION_S = 1

  TRACK_REPO_PREFIXES = /^(codemirror-lang|eslint-config|babel-preset|highlightjs)-/i
  TRACK_REPO_SUFFIXES = /-(test-runner|analyzer|representer|lib-jest-extensions|lib-static-analysis|docker-base)$/i

  TRACK_HELPER_REPOS = {
    "dotnet-tests" => "csharp",
    "eslint-config-tooling" => "typescript"
  }.freeze
end
