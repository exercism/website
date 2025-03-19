class Courses::BundleCodingFrontEnd < Courses::Course
  include Singleton

  def full_price = 149

  def default_payment_url = ""

  def slug = "bundle-coding-front-end"
  def template_slug = "bundle_coding_front_end"
  def name = "Coding & Front End Fundamentals"

  def blurb = Markdown::Parse.(
    "Build rock solid coding fundamentals and front-end web development skills! Perfect for **total beginners** or anyone who wants to **build more solid foundations.**"
  )
end
