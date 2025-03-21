class Courses::BundleCodingFrontEnd < Courses::Course
  include Singleton

  def enable_for_user!(user)
    Courses::Course.course_for_slug("coding-fundamentals").enable_for_user!(user)
    Courses::Course.course_for_slug("front-end-fundamentals").enable_for_user!(user)
  end

  def full_price = 149.99

  def default_payment_url = ""

  def slug = "bundle-coding-front-end"
  def template_slug = "bundle_coding_front_end"
  def name = "Coding & Front-End Fundamentals"

  # rubocop:disable Layout/LineLength
  def blurb = Markdown::Parse.(
    "Build rock solid coding fundamentals and front-end web development skills! Perfect for **total beginners** or anyone who wants to **build more solid foundations.**"
  )
  # rubocop:enable Layout/LineLength
end
