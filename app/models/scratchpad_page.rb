class ScratchpadPage < ApplicationRecord
  belongs_to :about, polymorphic: true
  belongs_to :author, # rubocop:disable Rails/InverseOf
    class_name: "User",
    foreign_key: "user_id"

  has_markdown_field :content

  validates :content_markdown, presence: true

  def category
    case about
    when Exercise
      "mentoring:exercise"
    end
  end

  def title
    case about
    when Exercise
      "#{about.track.slug}:#{about.slug}"
    end
  end
end
