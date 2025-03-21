class CourseEnrollment < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :user, optional: true

  def course
    Courses::Course.course_for_slug(course_slug)
  end

  def paid? = paid_at.present?
  def price = pricing_data[:dollars]
  def stripe_price_id = pricing_data[:stripe_id]

  def paid!
    update!(
      paid_at: Time.current,
      access_code: SecureRandom.hex(8)
    )

    if user
      course.enable_for_user!(user)
    else
      user = User.find_by(email:)
      if user
        update!(user:)
        course.enable_for_user!(user)
      end
    end
  end

  private
  memoize
  def pricing_data
    course.stripe_prices[country_code_2]
  end
end
