class Submission::Analysis < ApplicationRecord
  extend Mandate::Memoize
  include HasToolingJob

  serialize :data, JSON
  serialize :tags_data, JSON

  belongs_to :submission
  belongs_to :track

  scope :ops_successful, -> { where(ops_status: 200) }
  scope :with_comments, -> { where('num_comments > 0') }

  before_create do
    self.num_comments = self.comment_blocks.size
  end

  before_validation on: :create do
    self.track = submission.track unless track
  end

  memoize
  def has_comments? = comment_blocks.present?

  memoize
  def num_comments_by_type
    TYPES.index_with { |_t| 0 }.tap do |vals|
      comment_blocks.count do |block|
        type = block.try(:fetch, 'type', DEFAULT_TYPE).try(:to_sym) || DEFAULT_TYPE
        if vals[type]
          vals[type] += 1
        else
          Github::Issue::Open.(
            analyzer_repo,
            "Invalid analysis type: #{type}",
            "A comment was made with the type `#{type}`. This is invalid."
          )
        end
      end
    end
  rescue StandardError => e
    Github::Issue::Open.(analyzer_repo, e.message, e.backtrace)
    Bugsnag.notify(e)

    {}
  end

  %i[essential actionable informative celebratory].each do |type|
    define_method "num_#{type}_comments" do
      num_comments_by_type[type]
    end

    define_method "has_#{type}_comments?" do
      send("num_#{type}_comments").positive?
    end
  end

  memoize
  def summary = data[:summary].presence

  memoize
  def tags = tags_data[:tags].to_a

  memoize
  def comments
    repo = Git::WebsiteCopy.new

    comments = comment_blocks.map do |block|
      if block.is_a?(Hash)
        template = block['comment']
        params = block['params']
        type = block['type']
      else
        template = block
      end

      markdown = repo.analysis_comment_for(template) % (params || {}).symbolize_keys

      {
        type: type&.to_sym || DEFAULT_TYPE,
        html: Markdown::Parse.(markdown)
      }
    rescue StandardError => e
      Github::Issue::Open.(analyzer_repo, e.message, e.backtrace)
      Bugsnag.notify(e)

      nil
    end

    comments.compact.sort_by { |c| TYPES.index(c[:type]) }
  end

  def ops_success? = ops_status == 200
  def ops_errored? = !ops_success?

  private
  def comment_blocks
    data[:comments].to_a
  end

  memoize
  def data = HashWithIndifferentAccess.new(super)

  memoize
  def tags_data = HashWithIndifferentAccess.new(super)

  def analyzer_repo = "#{submission.track.slug}-analyzer"

  TYPES = %i[essential actionable informative celebratory].freeze
  DEFAULT_TYPE = :informative
  private_constant :TYPES, :DEFAULT_TYPE
end
