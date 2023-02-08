class StreamingEvent < ApplicationRecord
  def self.live
    where('starts_at <= NOW() and ends_at >= NOW()').first
  end

  def self.next_featured
    where(featured: true).
      where('starts_at > NOW()').
      order(:starts_at).
      first
  end

  def self.next_5
    where('starts_at > NOW()').
      order(:starts_at).
      first(5)
  end

  def youtube?
    youtube_id.present?
  end
end
