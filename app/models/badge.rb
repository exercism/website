class Badge < ApplicationRecord
  has_many :acquired_badges, class_name: "User::AcquiredBadge", dependent: :destroy

  RARITIES = %i[common rare ultimate legendary].freeze

  scope :ordered_by_rarity, -> { order(Arel.sql("FIND_IN_SET(rarity, 'legendary,ultimate,rare,common')")) }

  def self.seed(name, rarity, icon, description)
    raise "Incorrect Rarity" unless RARITIES.include?(rarity)

    @seed_data = {
      name:,
      rarity:,
      icon:,
      description:
    }
  end

  class << self
    attr_reader :seed_data
  end

  def reseed!
    update!(self.class.seed_data)
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

  def send_email_on_acquisition? = raise "Implement this method in the child class"

  # Stub that children can override to generate
  # notifications when they are created
  def notification_key; end

  # Stub to allow badges to short-circuit queueing
  def self.worth_queuing?(**_context) = true
  def award_to?(_user) = raise "Implement this method in the child class"

  def rarity = super.to_sym
  def icon = super.to_sym

  def percentage_awardees
    ((num_awardees / num_users.to_f) * 100).ceil(2)
  end

  def num_users
    query = <<~QUERY
      SELECT TABLE_ROWS
      FROM INFORMATION_SCHEMA.TABLES
      WHERE TABLE_NAME='#{User.table_name}'
      AND TABLE_SCHEMA='#{ActiveRecord::Base.connection.current_database}'
      LIMIT 1;
    QUERY

    ActiveRecord::Base.connection.select_value(query)
  end
end
