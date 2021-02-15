class User::Notification < ApplicationRecord
  include IsParamaterisedSTI
  self.class_suffix = :notification
  self.i18n_category = :notifications

  enum email_status: { pending: 0, skipped: 1, sent: 2, failed: 3 }

  belongs_to :user

  scope :read, -> { where.not(read_at: nil) }
  scope :unread, -> { where(read_at: nil) }

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end

  def read?
    read_at.present?
  end

  def read!
    update_column(:read_at, Time.current)
  end

  def cachable_rendering_data
    {
      id: uuid,
      url: url,
      text: text,
      created_at: created_at.iso8601,
      image_type: image_type,
      image_url: image_url
    }
  end

  def non_cachable_rendering_data
    {
      is_read: read?
    }
  end

  # TODO
  def url
    "/"
  end
end
