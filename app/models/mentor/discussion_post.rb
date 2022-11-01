class Mentor::DiscussionPost < ApplicationRecord
  belongs_to :discussion, counter_cache: :num_posts

  belongs_to :author, # rubocop:disable Rails/InverseOf
    class_name: "User",
    foreign_key: "user_id"

  belongs_to :iteration

  has_one :solution, through: :iteration

  validates :content_markdown, presence: true

  has_markdown_field :content, strip_h1: false, lower_heading_levels_by: 2

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end

  def by_student?
    discussion.student == author
  end

  def to_param = uuid

  delegate :idx, to: :iteration, prefix: true
end
