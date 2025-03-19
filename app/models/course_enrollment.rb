class CourseEnrollment < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :user, optional: true

  def course
    Courses::Course.course_for_slug(course_slug)
  end

  def price = pricing_data[:dollars]
  def stripe_price_id = pricing_data[:stripe_id]

  private
  memoize
  def pricing_data
    course.stripe_prices[country_code_2]
  end
end
