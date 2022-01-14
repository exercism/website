class BlogPost < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper

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

  def image_url
    attributes['image_url'].presence ||
      [
        Rails.application.config.action_controller.asset_host,
        compute_asset_path("graphics/blog-placeholder-article.svg")
      ].compact.join('/')
  end

  # TODO: Guarantee all posts have descriptions instead
  def description
    super.presence || marketing_copy
  end

  def content_html
    markdown = Git::Blog.content_for(slug)
    Markdown::Parse.(markdown.to_s, lower_heading_levels_by: 0)
  end
end
