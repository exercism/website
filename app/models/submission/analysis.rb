class Submission::Analysis < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :submission

  scope :ops_successful, -> { where(ops_status: 200) }

  def has_comments?
    comment_blocks.present?
  end

  memoize
  def num_comments_by_type
    {
      essential: 0,
      actionable: 0,
      informative: 0,
      celebratory: 0
    }.tap do |vals|
      comment_blocks.count do |block|
        type = block.try(:fetch, 'type').try(:to_sym) || :actionable
        vals[type] += 1
      end
    end
  end

  %i[essential actionable informative celebratory].each do |type|
    define_method "num_#{type}_comments" do
      num_comments_by_type[type]
    end

    define_method "has_#{type}_comments?" do
      send("num_#{type}_comments").positive?
    end
  end

  def feedback_html
    repo = Git::WebsiteCopy.new

    markdown_blocks = comment_blocks.map do |data|
      if data.is_a?(Hash)
        template = data['comment']
        params = data['params']
      else
        template = data
      end

      repo.analysis_comment_for(template) % (params || {}).symbolize_keys
    end

    Markdown::Parse.(markdown_blocks.join("\n---\n"))
  end

  def ops_success?
    ops_status == 200
  end

  def ops_errored?
    !ops_success?
  end

  private
  def comment_blocks
    data[:comments].to_a
  end

  memoize
  def data
    HashWithIndifferentAccess.new(super)
  end
end
