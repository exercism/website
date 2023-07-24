class User::Notification < ApplicationRecord
  include IsParamaterisedSTI
  include Emailable
  extend Mandate::Memoize

  self.class_suffix = :notification
  self.i18n_category = :notifications

  belongs_to :user

  # If track or exercise is set, it means that this is a
  # notification *about* that track and/or exercise and that
  # the blue notification dot should propogate everywhere
  belongs_to :track, optional: true
  belongs_to :exercise, optional: true

  enum status: { pending: 0, unread: 1, read: 2, email_only: 3 }

  scope :pending_or_unread, -> { where(status: %i[pending unread]) }
  scope :visible, -> { where(status: %i[unread read]) }

  before_validation on: :create do
    self.uuid = SecureRandom.compact_uuid
    self.path = "/#{url.split('/')[3..].join('/')}"
  end

  memoize
  def email_type
    type.gsub(/_notification$/, '')
  end

  memoize
  def email_communication_preferences_key = "email_on_#{type}"

  def email_should_send?
    unread? || email_only?
  end

  def status = super.to_sym

  def read!
    update_columns(
      status: :read,
      read_at: Time.current
    )
  end

  def cacheable_rendering_data
    {
      uuid:,
      url:,
      text:,
      created_at: created_at.iso8601,
      image_type:,
      image_url:
    }
  end

  def non_cacheable_rendering_data
    {
      is_read: read?,
      # This could go into cacheable but I don't want to have
      # to recache everything just for this, so I'm putting it here.
      icon_filter:

    }
  end

  def image_url = "#{Rails.application.config.action_controller.asset_host}#{compute_asset_path(image_path)}"
  def icon_filter = "textColor6"

  private
  memoize
  def type
    self.class.name.underscore.split('/').last
  end
end
