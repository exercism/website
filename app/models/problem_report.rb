class ProblemReport < ApplicationRecord
  disable_sti!

  enum type: {
    other: 0,
    bug: 1,
    coc: 2,
    mentoring: 3
  }
  belongs_to :user
  belongs_to :track, optional: true
  belongs_to :exercise, optional: true
  belongs_to :about, polymorphic: true, optional: true

  has_markdown_field :content

  def type = super.to_sym
end
