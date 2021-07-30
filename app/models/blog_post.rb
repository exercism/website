class BlogPost < ApplicationRecord
  extend FriendlyId
  friendly_id :slug, use: [:history]

  belongs_to :author, class_name: 'User'

  scope :published, -> { where('published_at <= ?', Time.current) }
  scope :scheduled, -> { where('published_at > ?', Time.current) }
  scope :ordered_by_recency, -> { order('published_at DESC') }

  def self.categories
    BlogPost.published.distinct.pluck(:category).sort
  end

  def self.categories_with_counts
    BlogPost.published.group(:category).count.sort_by(&:first)
  end

  def new?
    published_at > 7.days.ago
  end

  def video?
    youtube_id.present?
  end

  def to_param
    slug
  end

  # TODO: Guarantee all posts have image_urls instead
  def image_url
    super.presence || "https://i9.ytimg.com/vi_webp/08yykgEH1p0/sddefault.webp?v=60de2fe7&sqp=CISAkIgG&rs=AOn4CLDnkwE1bvFAmPk3NPom0WF9AMx0FQ"
  end

  # TODO: Guarantee all posts have descriptions instead
  def description
    super.presence || marketing_copy
  end

  def content_html
    markdown = Git::Blog.content_for(slug)
    Markdown::Parse.(markdown.to_s)
  end
end
