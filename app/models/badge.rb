class Badge < ApplicationRecord
  has_many :acquired_badges, class_name: "User::AcquiredBadge", dependent: :destroy

  RARIRIES = %i[common rare ultimate legendary].freeze

  def self.seed(name, rarity, icon, description)
    raise "Incorrect Rarity" unless RARIRIES.include?(rarity)

    @seed_data = {
      name: name,
      rarity: rarity,
      icon: icon,
      description: description
    }
  end

  # Badges are created on-demand, so if a new badge is added
  # to the code, it will get added to the database on first usage.
  #
  # This method gets or creates a badge by its slug
  def self.find_by_slug!(slug)
    klass = "badges/#{slug}_badge".camelize.constantize

    # This avoids race conditions
    begin
      klass.first || klass.create!
    rescue ActiveRecord::RecordNotUnique
      klass.first
    end
  end

  before_create do
    seed_data = self.class.instance_variable_get("@seed_data")

    self.name = seed_data[:name]
    self.rarity = seed_data[:rarity]
    self.icon = seed_data[:icon]
    self.description = seed_data[:description]
  end

  def award_to?(user)
    raise NotImplementedError
  end

  def rarity
    super.to_sym
  end

  def icon
    super.to_sym
  end
end
