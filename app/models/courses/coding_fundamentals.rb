class Courses::CodingFundamentals < Courses::Course
  include Singleton

  def full_price = 99

  def default_payment_url = ""

  def slug = "coding-fundamentals"
  def template_slug = "coding_fundamentals"
  def name = "Coding Fundamentals"

  def blurb = Markdown::Parse.(
    "Learn to code and build rock solid coding fundamentals! Perfect for **total beginners** or anyone who wants to **build more solid foundations.**"
  )

  def stripe_prices = STRIPE_PRICES

  STRIPE_PRICES = {
    "" => { dollars: 99.00, stripe_id: "price_1J5ZQzJ9Z6Z6Z6Z6" },
    "IN" => { dollars: 24.99, stripe_id: "price_1J5ZQzJ9Z6Z6Z6Z6" }
  }.freeze
end
