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
    youtube_url.present?
  end

  def to_param
    slug
  end

  def content
    markdown = Git::Blog.content_for(slug)
    Markdown::Parse.(markdown.to_s)
  end
end
