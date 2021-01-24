class Submission::Analysis < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :submission

  scope :ops_successful, -> { where(ops_status: 200) }

  def has_feedback?
    comment_blocks.present?
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
    data[:comments]
  end

  memoize
  def data
    HashWithIndifferentAccess.new(super)
  end
end
