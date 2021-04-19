class Exercise < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  # TODO: Remove this once we use external icons
  include Webpacker::Helper
  include ActionView::Helpers::AssetUrlHelper

  friendly_id :slug, use: [:history]

  belongs_to :track, counter_cache: :num_exercises

  # TODO: Pre-launch: Remove this dependent: :destroy  - exercises should never be destroyed
  has_many :solutions, dependent: :destroy
  has_many :submissions, through: :solutions

  # TODO: Pre-launch: Remove this dependent: :destroy - exercises should never be destroyed
  has_many :exercise_prerequisites,
    class_name: "Exercise::Prerequisite",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :prerequisites,
    through: :exercise_prerequisites,
    source: :concept

  # TODO: Pre-launch: Remove this dependent: :destroy - exercises should never be destroyed
  has_many :authorships,
    class_name: "Exercise::Authorship",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :authors,
    through: :authorships,
    source: :author

  # TODO: Pre-launch: Remove this dependent: :destroy - exercises should never be destroyed
  has_many :contributorships,
    class_name: "Exercise::Contributorship",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :contributors,
    through: :contributorships,
    source: :contributor

  scope :sorted, -> { order(:position) }

  scope :without_prerequisites, lambda {
    where.not(id: Exercise::Prerequisite.select(:exercise_id))
  }

  delegate :solution_files, :introduction, :instructions, :source, :source_url, to: :git

  before_create do
    self.synced_to_git_sha = git_sha unless self.synced_to_git_sha
  end

  def git_type
    self.class.name.sub("Exercise", "").downcase
  end

  def concept_exercise?
    is_a?(ConceptExercise)
  end

  def practice_exercise?
    is_a?(PracticeExercise)
  end

  def tutorial?
    slug == "hello-world"
  end

  def to_param
    slug
  end

  # TODO
  def download_cmd
    "exercism download --exercise=#{slug} --track=#{track.slug}".freeze
  end

  def icon_url
    # TODO: Fix this
    if EXERCISES_WITH_ICONS.include?(slug)
      # TOOD: Read correct dir
      "https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/exercises/#{slug}.svg"
    else
      asset_pack_url(
        "media/images/exercises/#{icon_name}.svg",
        host: Rails.application.config.action_controller.asset_host
      )
    end
  end

  # TODO: Delete once icon_url is implemented above
  def icon_name
    if title[0].ord < 70
      suffix = "queen-attack"
    elsif title[0].ord < 75
      suffix = "rocket"
    elsif title[0].ord < 80
      suffix = "minesweeper"
    elsif title[0].ord < 85
      suffix = "annalyn"
    else
      suffix = "butterflies"
    end

    "sample-#{suffix}"
  end

  def prerequisite_exercises
    ConceptExercise.that_teach(prerequisites).distinct
  end

  memoize
  def git
    Git::Exercise.new(slug, git_type, git_sha, repo_url: track.repo_url)
  end

  # TODO: Remove
  EXERCISES_WITH_ICONS = %w[
    annalyns-infiltration
    authentication-system
    beauty-salon-goes-global
    bird-watcher
    booking-up-for-beauty
    calculator-conundrum
    cars-assemble
    developer-privileges
    elons-toys
    faceid-2
    football-match-reports
    high-school-sweethearts
    hyperia-forex
    hyperinflation-hits-hyperia
    instruments-of-texas
    interest-is-interesting
    international-calling-connoisseur
    land-grab-in-space
    logs-logs-logs
    lucians-luscious-lasagna
    need-for-speed
    object-relational-mapping
    orm-in-one-go
    parsing-log-files
    phone-number-analysis
    all-your-base
    allergies
    atbash-cipher
    bank-account
    beer-song
    book-store
    bowling
    change
    clock
    crypto-square
    darts
    diamond
    gigasecond
    grade-school
    grains
    grep
    high-scores
    house
    kindergarten-garden
    matrix
    meetup
    minesweeper
    pascals-triangle
    phone-number
    poker
    protein-translation
    proverb
    queen-attack
    raindrops
    rectangles
    red-vs-blue-darwin-style
    remote-control-cleanup
    remote-control-competition
    resistor-color-duo
    resistor-color-trio
    resistor-color
    robot-name
    robot-simulator
    roll-the-die
    secret-handshake
    secure-munchester-united
    space-age
    squeaky-clean
    the-weather-in-deather
    tournament
    triangle
    two-bucket
    weighing-machine
    wizards-and-warriors-2
    wizards-and-warriors
    word-count
    yacht
    zipper
  ].freeze
end
