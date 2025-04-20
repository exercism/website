class CourseEnrollment < ApplicationRecord
  extend Mandate::Memoize
  include Emailable

  scope :paid, -> { where.not(paid_at: nil) }

  belongs_to :user, optional: true

  before_create do
    self.uuid = SecureRandom.uuid unless self.uuid
  end

  after_save do
    User::SyncToKit.defer(user) if user
  end

  def course
    Courses::Course.course_for_slug(course_slug)
  end

  # Always send emails
  def email_communication_preferences_key; end

  def paid? = paid_at.present?
  def price = pricing_data[:dollars]
  def stripe_price_id = pricing_data[:stripe_id]

  def paid!
    update!(
      paid_at: Time.current,
      access_code: SecureRandom.hex(8)
    )

    # Try and link the user via email
    unless user
      discovered_user = User.find_by(email:)
      update!(user: discovered_user) if discovered_user
    end

    # If we've got a user via any means, enable.
    course.enable_for_user!(user) if user

    # Make sure to do this below the email check
    course.send_welcome_email!(self)
  end

  def link_to_user!(user)
    update!(user:)
    course.enable_for_user!(user) if paid?
  end

  private
  memoize
  def pricing_data
    course.stripe_prices[country_code_2.presence || "DEFAULT"] ||
      course.stripe_prices["DEFAULT"]
  end
end
