class User::BootcampData < ApplicationRecord
  belongs_to :user, optional: true

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
    return unless package

    case package
    when 'complete'
      country_data ? country_data[2].to_f : COMPLETE_PRICE
    when 'part_1'
      country_data ? country_data[3].to_f : PART_1_PRICE
    end
  end

  def payment_url
    return unless package

    case package
    when 'complete'
      country_data ? country_data[4] : FULL_PAYMENT_URL
    when 'part_1'
      country_data ? country_data[5] : PART_1_PAYMENT_URL
    end
  end

  def stripe_price_id
    return unless package

    case package
    when 'complete'
      country_data ? country_data[6] : FULL_STRIPE_PRICE_ID
    when 'part_1'
      country_data ? country_data[7] : PART_1_STRIPE_PRICE_ID
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

  def has_discount? = country_data

  def discount_percentage
    ((COMPLETE_PRICE - @complete_price) / COMPLETE_PRICE * 100).round
  end

  DATA = JSON.parse(File.read(Rails.root / 'config' / 'bootcamp.json')).freeze
  COMPLETE_PRICE = 149.99
  PART_1_PRICE = 99.99
  FULL_STRIPE_PRICE_ID = "price_1QD0E7EoOT0Jqx0U9o3IND2o".freeze
  PART_1_STRIPE_PRICE_ID = "price_1QD0D3EoOT0Jqx0Uj2UvJ76j".freeze

  FULL_PAYMENT_URL = "https://buy.stripe.com/14k9BE4FBcyBeDmf0f".freeze
  PART_1_PAYMENT_URL = "https://buy.stripe.com/6oE4hk9ZVfKNeDm7xO".freeze
end
