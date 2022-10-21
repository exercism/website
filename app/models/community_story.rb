class CommunityStory < ApplicationRecord
  extend FriendlyId

  friendly_id :slug, use: [:history]

  belongs_to :interviewer, class_name: 'User'
  belongs_to :interviewee, class_name: 'User'

  scope :published, -> { where('published_at <= ?', Time.current) }
  scope :scheduled, -> { where('published_at > ?', Time.current) }
  scope :ordered_by_recency, -> { order('published_at DESC') }

  def video? = youtube_id.present?
  def to_param = slug

  # TODO: access transcript_html
end
