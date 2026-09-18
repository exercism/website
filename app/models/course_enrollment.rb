class CourseEnrollment < ApplicationRecord
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

  def paid? = paid_at.present?

  def link_to_user!(user)
    update!(user:)
    course.enable_for_user!(user) if paid?
  end
end
