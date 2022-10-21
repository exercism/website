class CommunityStory < ApplicationRecord
  extend FriendlyId

  friendly_id :slug, use: [:history]

  belongs_to :interviewer, class_name: 'User'
  belongs_to :interviewee, class_name: 'User'

  scope :published, -> { where('published_at <= ?', Time.current) }
  scope :scheduled, -> { where('published_at > ?', Time.current) }
  scope :ordered_by_recency, -> { order('published_at DESC') }

  def to_param = slug

  def content_html = Markdown::Parse.(content)
  def content = Git::Blog.story_content_for(slug).to_s

  def youtube_external_url = "https://www.youtube.com/watch?v=#{youtube_id}"
  def youtube_embed_url = "https://www.youtube.com/embed/#{youtube_id}"
end
