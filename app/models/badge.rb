class Badge < ApplicationRecord
  RARIRIES = %i[common rare ultimate legendary].freeze

  belongs_to :user

  def self.badge(name, rarity, icon, description)
    raise "Incorrect Rarity" unless RARIRIES.include?(rarity)

    @name = name
    @rarity = rarity
    @icon = icon
    @description = description
  end

  %i[name rarity icon description].each do |attr|
    define_method(attr) { self.class.instance_variable_get("@#{attr}") }
  end

  def self.slug_to_type(slug)
    "badges/#{slug}_badge".camelize
  end

  def should_award?
    raise NotImplementedError
  end
end
