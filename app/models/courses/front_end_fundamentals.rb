class Courses::FrontEndFundamentals < Courses::Course
  include Singleton

  def full_price = 99

  def default_payment_url = ""

  def slug = "front-end-fundamentals"
  def template_slug = "front_end_fundamentals"
  def name = "Front-end Fundamentals"

  def blurb = Markdown::Parse.(
    "Add front end skills to your coding repertoire. Designed for people **with a solid grasp of coding basics**. No web-dev experience required!"
  )

  def stripe_prices = STRIPE_PRICES

  STRIPE_PRICES = {
    "" => { dollars: 99.00, stripe_id: "price_1J5ZQzJ9Z6Z6Z6Z6" },
    "IN" => { dollars: 24.99, stripe_id: "price_1J5ZQzJ9Z6Z6Z6Z6" }
  }.freeze
end
