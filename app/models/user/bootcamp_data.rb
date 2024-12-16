class User::BootcampData < ApplicationRecord
  serialize :utm, JSON

  belongs_to :user, optional: true

  scope :enrolled, -> { where.not(enrolled_at: nil) }
  scope :paid, -> { where.not(paid_at: nil) }
  scope :not_enrolled, -> { where(enrolled_at: nil) }
  scope :not_paid, -> { where(paid_at: nil) }

  after_save do
    User::Bootcamp::SubscribeToOnboardingEmails.defer(self)
  end

  def self.to_tsv(status: :enrolled_unpaid)
    return unless status == :enrolled_unpaid

    data = where.not(enrolled_at: nil).where(paid_at: nil)
    data.map do |row|
      [
        row.name, row.email, row.price, row.payment_url
      ].join("\t")
    end.join("\n")
  end

  def enrolled? = enrolled_at.present?
  def paid? = paid_at.present?

  def price
    if package == "part_1"
      country_data ? country_data[3].to_f : PART_1_PRICE
    else
      country_data ? country_data[2].to_f : COMPLETE_PRICE
    end
  end

  def payment_url
    if package == "part_1"
      country_data ? country_data[5] : PART_1_PAYMENT_URL
    else
      country_data ? country_data[4] : FULL_PAYMENT_URL
    end
  end

  def stripe_price_id
    if package == "part_1"
      country_data ? country_data[7] : PART_1_STRIPE_PRICE_ID
    else
      country_data ? country_data[6] : FULL_STRIPE_PRICE_ID
    end
  end

  def country_name
    return unless country_data

    country_data[0]
  end

  def country_data
    return unless ppp_country

    DATA[ppp_country]
  end

  def has_discount? = !!country_data

  def discount_percentage
    if package == 'part_1'
      ((PART_1_PRICE - price) / PART_1_PRICE * 100).round
    else
      ((COMPLETE_PRICE - price) / COMPLETE_PRICE * 100).round
    end
  end

  DATA = JSON.parse(File.read(Rails.root / 'config' / 'bootcamp.json')).freeze
  COMPLETE_PRICE = 149.99
  PART_1_PRICE = 99.99
  FULL_STRIPE_PRICE_ID = "price_1QD0E7EoOT0Jqx0U9o3IND2o".freeze
  PART_1_STRIPE_PRICE_ID = "price_1QD0D3EoOT0Jqx0Uj2UvJ76j".freeze

  FULL_PAYMENT_URL = "https://buy.stripe.com/14k9BE4FBcyBeDmf0f".freeze
  PART_1_PAYMENT_URL = "https://buy.stripe.com/6oE4hk9ZVfKNeDm7xO".freeze
end
