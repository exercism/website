class Submission::Analysis < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :submission

  scope :ops_successful, -> { where(ops_status: 200) }

  def has_feedback?
    markdown_comments.present?
  end

  def feedback_html
    # TODO: Do this properly
    Markdown::Parse.(markdown_comments.join("\n---\n"))
  end

  def ops_success?
    ops_status == 200
  end

  def ops_errored?
    !ops_success?
  end

  private
  def markdown_comments
    data[:comments]
  end

  memoize
  def data
    HashWithIndifferentAccess.new(super)
  end
end
