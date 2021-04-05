class User::Notification < ApplicationRecord
  include IsParamaterisedSTI
  self.class_suffix = :notification
  self.i18n_category = :notifications

  # If track or exercise is set, it means that this is a
  # notification *about* that track and/or exercise and that
  # the blue notification dot should propogate everywhere
  belongs_to :track, optional: true
  belongs_to :exercise, optional: true

  enum status: { pending: 0, unread: 1, read: 2 }
  enum email_status: { pending: 0, skipped: 1, sent: 2, failed: 3 }, _prefix: :email

  scope :pending_or_unread, -> { where(status: %i[pending unread]) }

  before_validation on: :create do
    self.uuid = SecureRandom.compact_uuid
    self.path = "/#{url.split('/')[3..].join('/')}"
  end

  def status
    super.to_sym
  end

  def read!
    update_columns(
      status: :read,
      read_at: Time.current
    )
  end

  def cacheable_rendering_data
    {
      id: uuid,
      url: url,
      text: text,
      created_at: created_at.iso8601,
      image_type: image_type,
      image_url: image_url
    }
  end

  def non_cacheable_rendering_data
    {
      is_read: read?
    }
  end
end
