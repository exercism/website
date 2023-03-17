class StreamingEvent < ApplicationRecord
  scope :live, -> { where('starts_at <= NOW() AND ends_at >= NOW()') }
  scope :scheduled, -> { where('starts_at > NOW()') }
  scope :featured, -> { where(featured: true) }

  def self.current_live = live.first
  def self.next_featured = scheduled.featured.order(:starts_at).first
  def self.next_5 = scheduled.order(:starts_at).first(5)

  def youtube? = youtube_id.present?

  def youtube_external_url
    "https://www.youtube.com/watch?v=#{youtube_id}" if youtube?
  end

  def youtube_embed_url
    "https://www.youtube.com/embed/#{youtube_id}" if youtube?
  end
end
